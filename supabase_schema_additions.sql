-- ============================================================
-- SCHEMA ADDITIONS — Run these in Supabase SQL Editor
-- ============================================================

-- 1. Add notes column to customers
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS notes TEXT;

-- 2. Add UNIQUE constraint on phone per vendor (duplicate handling)
-- Only add if it doesn't already exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'customers_vendor_phone_unique'
  ) THEN
    ALTER TABLE public.customers 
      ADD CONSTRAINT customers_vendor_phone_unique UNIQUE (vendor_id, phone);
  END IF;
END $$;

-- 3. Bills table (for billing engine output)
CREATE TABLE IF NOT EXISTS public.bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    billing_month INTEGER NOT NULL,
    billing_year INTEGER NOT NULL,
    total_liters DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) DEFAULT 0,
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    pending_amount DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'paid')),
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (vendor_id, customer_id, billing_month, billing_year)
);

CREATE INDEX IF NOT EXISTS idx_bills_vendor_month ON public.bills(vendor_id, billing_month, billing_year);

-- Enable RLS on bills
ALTER TABLE public.bills ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Vendors can manage own bills" ON public.bills;
CREATE POLICY "Vendors can manage own bills" ON public.bills
    FOR ALL USING (vendor_id = get_vendor_id());

-- Enable RLS on vacation_requests and emergency_requests
ALTER TABLE public.vacation_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Vendors can manage own vacation requests" ON public.vacation_requests;
CREATE POLICY "Vendors can manage own vacation requests" ON public.vacation_requests
    FOR ALL USING (vendor_id = get_vendor_id());

ALTER TABLE public.emergency_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Vendors can manage own emergency requests" ON public.emergency_requests;
CREATE POLICY "Vendors can manage own emergency requests" ON public.emergency_requests
    FOR ALL USING (vendor_id = get_vendor_id());

-- 4. Supabase Storage: Create vendor-logos bucket (run manually if needed)
-- insert into storage.buckets (id, name, public) values ('vendor-logos', 'vendor-logos', true);
-- CREATE POLICY "Vendors can upload own logo" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'vendor-logos' AND auth.uid()::text = (storage.foldername(name))[1]);
-- CREATE POLICY "Logos are public" ON storage.objects FOR SELECT USING (bucket_id = 'vendor-logos');

-- 5. generate_monthly_bills RPC function
CREATE OR REPLACE FUNCTION generate_monthly_bills(p_month INTEGER, p_year INTEGER)
RETURNS void AS $$
DECLARE
  v_vendor_id UUID;
  v_customer RECORD;
  v_total_liters DECIMAL;
  v_total_amount DECIMAL;
  v_price DECIMAL := 60; -- default price if no milk_type linked
BEGIN
  v_vendor_id := get_vendor_id();

  FOR v_customer IN
    SELECT id FROM public.customers WHERE vendor_id = v_vendor_id AND is_active = TRUE
  LOOP
    -- Sum deliveries for this customer in this month/year
    SELECT
      COALESCE(SUM(d.quantity), 0),
      COALESCE(SUM(d.quantity * d.price_applied), 0)
    INTO v_total_liters, v_total_amount
    FROM public.deliveries d
    WHERE d.customer_id = v_customer.id
      AND EXTRACT(MONTH FROM d.delivery_date) = p_month
      AND EXTRACT(YEAR FROM d.delivery_date) = p_year;

    -- Only generate a bill if there were deliveries
    IF v_total_liters > 0 THEN
      INSERT INTO public.bills (vendor_id, customer_id, billing_month, billing_year, total_liters, total_amount, pending_amount, status)
      VALUES (v_vendor_id, v_customer.id, p_month, p_year, v_total_liters, v_total_amount, v_total_amount, 'pending')
      ON CONFLICT (vendor_id, customer_id, billing_month, billing_year)
      DO UPDATE SET
        total_liters = EXCLUDED.total_liters,
        total_amount = EXCLUDED.total_amount,
        pending_amount = GREATEST(EXCLUDED.total_amount - bills.paid_amount, 0),
        updated_at = NOW();
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- ADDITIONS TO FIX RECENT ERRORS (RUN THESE)
-- ============================================================

-- 1. Vendors RLS Policies (Allow inserting/updating own profile)
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Vendors can insert own profile" ON public.vendors;
CREATE POLICY "Vendors can insert own profile" ON public.vendors
    FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Vendors can update own profile" ON public.vendors;
CREATE POLICY "Vendors can update own profile" ON public.vendors
    FOR UPDATE USING (user_id = auth.uid());

-- 2. User Roles RPC
CREATE OR REPLACE FUNCTION set_user_role(p_role TEXT)
RETURNS void AS $$
BEGIN
  UPDATE auth.users SET raw_user_meta_data = 
    COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('role', p_role)
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
DECLARE
  v_role TEXT;
BEGIN
  SELECT raw_user_meta_data->>'role' INTO v_role
  FROM auth.users
  WHERE id = auth.uid();
  RETURN COALESCE(v_role, 'customer');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Storage Bucket 'vendor-logos' (Must run as superuser)
insert into storage.buckets (id, name, public) values ('vendor-logos', 'vendor-logos', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Vendors can upload own logo" ON storage.objects;
CREATE POLICY "Vendors can upload own logo" ON storage.objects 
    FOR INSERT WITH CHECK (bucket_id = 'vendor-logos' AND auth.uid()::text = (storage.foldername(name))[1]);

DROP POLICY IF EXISTS "Logos are public" ON storage.objects;
CREATE POLICY "Logos are public" ON storage.objects 
    FOR SELECT USING (bucket_id = 'vendor-logos');


-- ============================================================
-- FIX VENDOR_ID INSERTS & FOREIGN KEYS
-- ============================================================
ALTER TABLE public.customers ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
ALTER TABLE public.milk_types ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
ALTER TABLE public.deliveries ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
ALTER TABLE public.payments ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
ALTER TABLE public.vendor_settings ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
ALTER TABLE public.bills ALTER COLUMN vendor_id SET DEFAULT get_vendor_id();
