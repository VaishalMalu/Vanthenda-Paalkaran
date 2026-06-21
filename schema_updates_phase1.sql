-- Phase 1 Schema Updates
-- Run this in your Supabase SQL Editor

-- 1. Add new columns to Customers table
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8);
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8);
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS apartment VARCHAR(255);
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS street VARCHAR(255);
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS route VARCHAR(255);

-- 2. Create Staff table
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL CHECK (role IN ('Manager', 'Delivery Boy', 'Accountant')),
    passcode VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable RLS and Policies for Staff
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Vendors can manage own staff" ON public.staff;
CREATE POLICY "Vendors can manage own staff" ON public.staff
    FOR ALL USING (vendor_id = get_vendor_id());

-- 4. Triggers for Staff updated_at
DROP TRIGGER IF EXISTS update_staff_updated_at ON public.staff;
CREATE TRIGGER update_staff_updated_at BEFORE UPDATE ON public.staff FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
