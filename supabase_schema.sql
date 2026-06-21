-- Vanthenda Paalkaran - Complete Supabase PostgreSQL Schema
-- Includes Tables, RLS Policies, Indexes, and Triggers

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 0. CLEANUP EXISTING SCHEMA (For fresh setup)
-- ==========================================
DROP TABLE IF EXISTS public.analytics_snapshots CASCADE;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.invoice_templates CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.emergency_requests CASCADE;
DROP TABLE IF EXISTS public.vacation_requests CASCADE;
DROP TABLE IF EXISTS public.payments CASCADE;
DROP TABLE IF EXISTS public.deliveries CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.milk_types CASCADE;
DROP TABLE IF EXISTS public.vendor_settings CASCADE;
DROP TABLE IF EXISTS public.vendors CASCADE;

-- ==========================================
-- 1. VENDORS TABLE
-- ==========================================
CREATE TABLE IF NOT EXISTS public.vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    logo_url TEXT,
    upi_id VARCHAR(100),
    gst_number VARCHAR(15),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendors_user_id ON public.vendors(user_id);

-- ==========================================
-- 2. VENDOR SETTINGS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.vendor_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    default_language VARCHAR(10) DEFAULT 'ta',
    currency VARCHAR(10) DEFAULT 'INR',
    invoice_prefix VARCHAR(10) DEFAULT 'INV-',
    enable_notifications BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. MILK TYPES
-- ==========================================
CREATE TABLE IF NOT EXISTS public.milk_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL, -- Cow Milk, Buffalo Milk, A2
    description TEXT,
    price_per_liter DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 4. CUSTOMERS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    notes TEXT,
    customer_group VARCHAR(100) DEFAULT 'General',
    default_milk_type_id UUID REFERENCES public.milk_types(id) ON DELETE SET NULL,
    default_morning_qty DECIMAL(5, 2) DEFAULT 0,
    default_evening_qty DECIMAL(5, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_customers_vendor_id ON public.customers(vendor_id);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers(phone);

-- ==========================================
-- 5. DELIVERIES (Digital Milk Card)
-- ==========================================
CREATE TABLE IF NOT EXISTS public.deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    milk_type_id UUID REFERENCES public.milk_types(id),
    delivery_date DATE NOT NULL,
    session VARCHAR(10) NOT NULL CHECK (session IN ('Morning', 'Evening', 'Extra')),
    quantity DECIMAL(5, 2) NOT NULL,
    price_applied DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Delivered' CHECK (status IN ('Delivered', 'Skipped', 'Paused')),
    sync_status VARCHAR(20) DEFAULT 'Synced',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (customer_id, delivery_date, session)
);

CREATE INDEX IF NOT EXISTS idx_deliveries_vendor_date ON public.deliveries(vendor_id, delivery_date);
CREATE INDEX IF NOT EXISTS idx_deliveries_customer_date ON public.deliveries(customer_id, delivery_date);

-- ==========================================
-- 6. PAYMENTS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    payment_mode VARCHAR(50) NOT NULL CHECK (payment_mode IN ('Cash', 'UPI', 'Bank Transfer', 'Razorpay')),
    transaction_id VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_vendor_id ON public.payments(vendor_id);
CREATE INDEX IF NOT EXISTS idx_payments_customer_id ON public.payments(customer_id);

-- ==========================================
-- 7. VACATION REQUESTS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.vacation_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 8. EMERGENCY REQUESTS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.emergency_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    request_date DATE NOT NULL,
    session VARCHAR(10) NOT NULL CHECK (session IN ('Morning', 'Evening')),
    additional_quantity DECIMAL(5, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 9. NOTIFICATIONS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'Payment', 'Emergency', 'Delivery'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 10. INVOICE TEMPLATES
-- ==========================================
CREATE TABLE IF NOT EXISTS public.invoice_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    template_name VARCHAR(100) NOT NULL,
    header_text TEXT,
    footer_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 11. AUDIT LOGS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 12. ANALYTICS SNAPSHOTS
-- ==========================================
CREATE TABLE IF NOT EXISTS public.analytics_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    total_revenue DECIMAL(15, 2) DEFAULT 0,
    total_milk_sold DECIMAL(10, 2) DEFAULT 0,
    active_customers INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (vendor_id, snapshot_date)
);

-- ==========================================
-- UPDATED_AT TRIGGERS
-- ==========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_vendors_updated_at ON public.vendors;
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_customers_updated_at ON public.customers;
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_milk_types_updated_at ON public.milk_types;
CREATE TRIGGER update_milk_types_updated_at BEFORE UPDATE ON public.milk_types FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_deliveries_updated_at ON public.deliveries;
CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON public.deliveries FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON public.payments;
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

DROP TRIGGER IF EXISTS update_vendor_settings_updated_at ON public.vendor_settings;
CREATE TRIGGER update_vendor_settings_updated_at BEFORE UPDATE ON public.vendor_settings FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
-- Enable RLS
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milk_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Vendors Table: Users can only see and edit their own vendor profile
DROP POLICY IF EXISTS "Vendors can view own profile" ON public.vendors;
CREATE POLICY "Vendors can view own profile" ON public.vendors
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Vendors can update own profile" ON public.vendors;
CREATE POLICY "Vendors can update own profile" ON public.vendors
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Vendors can insert own profile" ON public.vendors;
CREATE POLICY "Vendors can insert own profile" ON public.vendors
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Helper function to get vendor_id for current user
CREATE OR REPLACE FUNCTION get_vendor_id() RETURNS UUID AS $$
    SELECT id FROM public.vendors WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER;

-- Customers Table: Vendors see only their own customers
DROP POLICY IF EXISTS "Vendors can manage own customers" ON public.customers;
CREATE POLICY "Vendors can manage own customers" ON public.customers
    FOR ALL USING (vendor_id = get_vendor_id());

-- Milk Types
DROP POLICY IF EXISTS "Vendors can manage own milk types" ON public.milk_types;
CREATE POLICY "Vendors can manage own milk types" ON public.milk_types
    FOR ALL USING (vendor_id = get_vendor_id());

-- Deliveries
DROP POLICY IF EXISTS "Vendors can manage own deliveries" ON public.deliveries;
CREATE POLICY "Vendors can manage own deliveries" ON public.deliveries
    FOR ALL USING (vendor_id = get_vendor_id());

-- Payments
DROP POLICY IF EXISTS "Vendors can manage own payments" ON public.payments;
CREATE POLICY "Vendors can manage own payments" ON public.payments
    FOR ALL USING (vendor_id = get_vendor_id());

-- Vendor Settings
DROP POLICY IF EXISTS "Vendors can manage own settings" ON public.vendor_settings;
CREATE POLICY "Vendors can manage own settings" ON public.vendor_settings
    FOR ALL USING (vendor_id = get_vendor_id());
