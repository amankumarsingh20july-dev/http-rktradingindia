-- ========================================================
-- Hardware Business Management System Database Schema
-- Compatible with SQLite, MySQL, and PostgreSQL
-- ========================================================

-- 1. Users / Staff Table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin', -- 'admin', 'cashier', 'manager'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Products Table
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku VARCHAR(50) UNIQUE NOT NULL,
    barcode VARCHAR(50),
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- Pcs, Kg, Box, Meter, Bag
    hsn_code VARCHAR(20),
    cost_price DECIMAL(10,2) NOT NULL,
    wholesale_price DECIMAL(10,2) NOT NULL,
    retail_price DECIMAL(10,2) NOT NULL,
    gst_rate DECIMAL(5,2) DEFAULT 18.00,
    current_stock DECIMAL(10,2) DEFAULT 0,
    min_stock_alert DECIMAL(10,2) DEFAULT 10,
    location_rack VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(150) NOT NULL,
    business_name VARCHAR(200),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    gstin VARCHAR(20),
    customer_type VARCHAR(20) DEFAULT 'Retail', -- 'Retail', 'Contractor', 'Wholesaler'
    credit_limit DECIMAL(12,2) DEFAULT 50000,
    outstanding_balance DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Suppliers Table
CREATE TABLE IF NOT EXISTS suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    gstin VARCHAR(20),
    outstanding_payable DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Purchases (Stock Inward) Table
CREATE TABLE IF NOT EXISTS purchases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_invoice_no VARCHAR(50) NOT NULL,
    supplier_id INTEGER,
    supplier_name VARCHAR(200),
    date DATE NOT NULL,
    subtotal_taxable DECIMAL(12,2) NOT NULL,
    total_tax DECIMAL(12,2) NOT NULL,
    grand_total DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) DEFAULT 0,
    due_amount DECIMAL(12,2) DEFAULT 0,
    payment_status VARCHAR(20) DEFAULT 'Paid', -- 'Paid', 'Partial', 'Unpaid'
    payment_mode VARCHAR(50) DEFAULT 'Bank Transfer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 6. Purchase Items Table
CREATE TABLE IF NOT EXISTS purchase_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(200),
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    purchase_rate DECIMAL(10,2) NOT NULL,
    taxable_amount DECIMAL(10,2) NOT NULL,
    gst_rate DECIMAL(5,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 7. Sales (Invoices / POS) Table
CREATE TABLE IF NOT EXISTS sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_no VARCHAR(50) UNIQUE NOT NULL,
    sale_type VARCHAR(20) DEFAULT 'retail', -- 'retail', 'wholesale'
    customer_id INTEGER,
    customer_name VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20),
    customer_gstin VARCHAR(20),
    date DATE NOT NULL,
    subtotal_taxable DECIMAL(12,2) NOT NULL,
    total_cgst DECIMAL(12,2) DEFAULT 0,
    total_sgst DECIMAL(12,2) DEFAULT 0,
    total_igst DECIMAL(12,2) DEFAULT 0,
    total_tax DECIMAL(12,2) NOT NULL,
    discount DECIMAL(12,2) DEFAULT 0,
    round_off DECIMAL(6,2) DEFAULT 0,
    grand_total DECIMAL(12,2) NOT NULL,
    payment_mode VARCHAR(50) DEFAULT 'Cash', -- Cash, UPI, Card, Credit/Khata
    paid_amount DECIMAL(12,2) NOT NULL,
    due_amount DECIMAL(12,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'Paid',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- 8. Sale Items Table
CREATE TABLE IF NOT EXISTS sale_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(200),
    sku VARCHAR(50),
    hsn_code VARCHAR(20),
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    rate DECIMAL(10,2) NOT NULL,
    taxable_amount DECIMAL(10,2) NOT NULL,
    gst_rate DECIMAL(5,2) NOT NULL,
    cgst_amount DECIMAL(10,2) DEFAULT 0,
    sgst_amount DECIMAL(10,2) DEFAULT 0,
    igst_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 9. Payments & Receipts Table
CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'Payment_In', 'Payment_Out'
    party_type VARCHAR(20) NOT NULL, -- 'Customer', 'Supplier', 'Other'
    party_id INTEGER,
    party_name VARCHAR(150) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_mode VARCHAR(50) NOT NULL,
    reference_no VARCHAR(100),
    related_invoice_no VARCHAR(50),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Expenses Table
CREATE TABLE IF NOT EXISTS expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(50) NOT NULL,
    paid_to VARCHAR(150),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. General Ledger & Khata Transactions
CREATE TABLE IF NOT EXISTS ledger (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL,
    party_type VARCHAR(20) NOT NULL, -- 'Customer' or 'Supplier'
    party_id INTEGER NOT NULL,
    reference_no VARCHAR(50),
    description TEXT,
    debit DECIMAL(12,2) DEFAULT 0,
    credit DECIMAL(12,2) DEFAULT 0,
    running_balance DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Stock Ledger / Audit Log
CREATE TABLE IF NOT EXISTS stock_ledger (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    movement_type VARCHAR(20) NOT NULL, -- 'PURCHASE', 'SALE', 'ADJUSTMENT'
    reference_id VARCHAR(50),
    quantity_changed DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    remarks TEXT,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Seed Sample Admin User
INSERT OR IGNORE INTO users (id, username, password_hash, full_name, role)
VALUES (1, 'admin', 'admin123', 'Rajesh Agarwal (Admin)', 'admin');
