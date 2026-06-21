-- ============================================================
-- RBAC Migration: Add user_id to customers & staff,
-- add get_user_role() function, update RLS policies
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Add user_id to customers (links customer record to auth account)
ALTER TABLE public.customers 
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_customers_user_id ON public.customers(user_id);

-- 2. Add user_id to staff
ALTER TABLE public.staff 
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_staff_user_id ON public.staff(user_id);

-- 3. Role detection function
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
DECLARE
  v_role TEXT;
BEGIN
  -- Check vendor first
  SELECT 'vendor' INTO v_role
    FROM public.vendors
    WHERE user_id = auth.uid()
    LIMIT 1;
  IF v_role IS NOT NULL THEN RETURN v_role; END IF;

  -- Check customer
  SELECT 'customer' INTO v_role
    FROM public.customers
    WHERE user_id = auth.uid() AND is_active = TRUE
    LIMIT 1;
  IF v_role IS NOT NULL THEN RETURN v_role; END IF;

  -- Check staff
  SELECT 'staff' INTO v_role
    FROM public.staff
    WHERE user_id = auth.uid() AND is_active = TRUE
    LIMIT 1;

  RETURN COALESCE(v_role, NULL);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Helper: get customer id for current auth user
CREATE OR REPLACE FUNCTION get_customer_id()
RETURNS UUID AS $$
  SELECT id FROM public.customers WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- 5. Helper: get vendor_id for current staff user
CREATE OR REPLACE FUNCTION get_staff_vendor_id()
RETURNS UUID AS $$
  SELECT vendor_id FROM public.staff WHERE user_id = auth.uid() AND is_active = TRUE LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================================
-- 6. Update RLS Policies
-- ============================================================

-- Customers: can read their own row
DROP POLICY IF EXISTS "Customers can view own profile" ON public.customers;
CREATE POLICY "Customers can view own profile" ON public.customers
  FOR SELECT USING (
    vendor_id = get_vendor_id()         -- vendor sees all their customers
    OR auth.uid() = user_id             -- customer sees own row
    OR vendor_id = get_staff_vendor_id() -- staff sees vendor's customers
  );

DROP POLICY IF EXISTS "Customers can update own profile" ON public.customers;
CREATE POLICY "Customers can update own profile" ON public.customers
  FOR UPDATE USING (
    vendor_id = get_vendor_id()
    OR auth.uid() = user_id
  );

-- Deliveries: customer sees own, staff sees their vendor's
DROP POLICY IF EXISTS "Vendors can manage own deliveries" ON public.deliveries;
CREATE POLICY "Vendors can manage own deliveries" ON public.deliveries
  FOR ALL USING (vendor_id = get_vendor_id());

DROP POLICY IF EXISTS "Customers can view own deliveries" ON public.deliveries;
CREATE POLICY "Customers can view own deliveries" ON public.deliveries
  FOR SELECT USING (
    vendor_id = get_vendor_id()
    OR customer_id = get_customer_id()
    OR vendor_id = get_staff_vendor_id()
  );

-- Payments: customer sees own payments
DROP POLICY IF EXISTS "Customers can view own payments" ON public.payments;
CREATE POLICY "Customers can view own payments" ON public.payments
  FOR SELECT USING (
    vendor_id = get_vendor_id()
    OR customer_id = get_customer_id()
  );

-- Vacation requests: customer can insert/view own
DROP POLICY IF EXISTS "Customers can manage own vacation" ON public.vacation_requests;
CREATE POLICY "Customers can manage own vacation" ON public.vacation_requests
  FOR ALL USING (
    vendor_id = get_vendor_id()
    OR customer_id = get_customer_id()
  );

-- Emergency requests: customer can insert/view own
DROP POLICY IF EXISTS "Customers can manage own emergency" ON public.emergency_requests;
CREATE POLICY "Customers can manage own emergency" ON public.emergency_requests
  FOR ALL USING (
    vendor_id = get_vendor_id()
    OR customer_id = get_customer_id()
  );

-- ============================================================
-- 7. Bills table RLS (if bills table exists)
-- ============================================================
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'bills' AND table_schema = 'public') THEN
    ALTER TABLE public.bills ENABLE ROW LEVEL SECURITY;
    
    EXECUTE 'DROP POLICY IF EXISTS "Bills access" ON public.bills';
    EXECUTE 'CREATE POLICY "Bills access" ON public.bills
      FOR SELECT USING (
        vendor_id = get_vendor_id()
        OR customer_id = get_customer_id()
      )';
  END IF;
END $$;

-- ============================================================
-- 8. Auto-link function for Phone OTP login
-- ============================================================
CREATE OR REPLACE FUNCTION public.link_phone_to_profile(p_phone TEXT)
RETURNS void AS $$
BEGIN
  -- Try to link customer
  UPDATE public.customers
  SET user_id = auth.uid()
  WHERE phone = p_phone
  AND user_id IS NULL;

  -- Try to link staff
  UPDATE public.staff
  SET user_id = auth.uid()
  WHERE phone = p_phone
  AND user_id IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- DONE. Run flutter analyze after updating Dart code.
-- ============================================================
