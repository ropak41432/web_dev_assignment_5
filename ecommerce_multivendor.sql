-- ============================================================================
-- Ostad Web Development - Module 5 Assignment
-- Multi-Vendor SaaS E-Commerce Platform Database Design
-- Database: PostgreSQL
-- ============================================================================

-- Drop tables in reverse order of foreign key dependencies
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;


-- ============================================================================
-- PART B: SQL DDL (Table Creation)
-- ============================================================================

-- 1. Subscription Plans Table
-- Holds tier details for vendor subscriptions
CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price NUMERIC(10, 2) NOT NULL,
    duration VARCHAR(50) NOT NULL,
    features TEXT
);

-- Question 3:
-- Write the SQL command to create a table for Vendor, including primary key
-- and foreign key reference to SubscriptionPlan.
CREATE TABLE vendors (
    id SERIAL PRIMARY KEY,
    business_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    business_address TEXT NOT NULL,
    subscription_plan_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vendor_subscription_plan
        FOREIGN KEY (subscription_plan_id)
        REFERENCES subscription_plans(id)
        ON DELETE RESTRICT
);

-- 3. Categories Table
-- Stores product categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 4. Products Table
-- Products listed by vendors (1:N relationship with Vendor)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    vendor_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_vendor
        FOREIGN KEY (vendor_id)
        REFERENCES vendors(id)
        ON DELETE CASCADE
);

-- Question 4:
-- Write the SQL command to create the ProductCategory table, ensuring
-- it properly handles the M:N relationship between Product and Category.
CREATE TABLE product_categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_productcategory_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_productcategory_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE CASCADE
);

-- 6. Customers Table
-- Registered customer accounts
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Orders Table
-- Orders placed by customers (1:N relationship with Customer)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE CASCADE
);

-- 8. Order Items Table
-- Line items within each order, linking order to product
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE RESTRICT
);

-- 9. Payments Table
-- Payment record for each order (1:1 relationship via UNIQUE order_id)
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    method VARCHAR(50) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'completed',
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
);


-- ============================================================================
-- SEED DATA (Base setup for testing queries 9 to 13)
-- ============================================================================

INSERT INTO subscription_plans (name, price, duration, features) VALUES
('Basic', 999.00, 'Monthly', 'Up to 50 products, standard support'),
('Standard', 1999.00, 'Monthly', 'Up to 200 products, priority support'),
('Premium', 4999.00, 'Monthly', 'Unlimited products, dedicated manager');

INSERT INTO categories (name, description) VALUES
('Electronics', 'Gadgets, computers, smartphones, and electronic devices'),
('Clothing', 'Men and women apparel and fashion items'),
('Home & Kitchen', 'Home appliances, kitchen utilities, and cookware');

INSERT INTO vendors (business_name, contact_person, email, phone, business_address, subscription_plan_id) VALUES
('Apex Gadgets', 'Tanvir Ahmed', 'tanvir@apexgadgets.com', '01811111111', 'Agrabad, Chittagong', 2),
('Fashion Hub', 'Nusrat Jahan', 'nusrat@fashionhub.com', '01922222222', 'Banani, Dhaka', 1);

INSERT INTO products (vendor_id, name, description, price, stock_quantity, status) VALUES
(1, 'Wireless Mouse', 'Ergonomic 2.4GHz optical wireless mouse', 1200.00, 50, 'active'),
(1, 'Mechanical Keyboard', 'RGB backlit mechanical gaming keyboard', 4500.00, 30, 'active'),
(1, 'Noise Cancelling Headphones', 'Over-ear Bluetooth active noise cancelling headphones', 8500.00, 20, 'active'),
(2, 'Cotton T-Shirt', '100% combed organic cotton regular fit t-shirt', 650.00, 100, 'active'),
(2, 'Denim Jeans', 'Slim fit stretch denim blue jeans', 2200.00, 45, 'active');

INSERT INTO product_categories (product_id, category_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2);

INSERT INTO customers (name, email, phone, address) VALUES
('Karim Uddin', 'karim.uddin@gmail.com', '01711223344', 'House 12, Road 5, Mirpur-10, Dhaka'),
('Sadia Rahman', 'sadia.rahman@gmail.com', '01655667788', 'Flat 4B, Dhanmondi 27, Dhaka'),
('Old Customer', 'oldcustomer@gmail.com', '01399887766', 'Sector 3, Uttara, Dhaka');

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2026-10-01', 5700.00, 'Delivered'),
(1, '2026-10-05', 8500.00, 'Processing'),
(2, '2026-10-07', 3500.00, 'Delivered');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 1200.00, 1200.00),
(1, 2, 1, 4500.00, 4500.00),
(2, 3, 1, 8500.00, 8500.00),
(3, 4, 2, 650.00, 1300.00),
(3, 5, 1, 2200.00, 2200.00);

INSERT INTO payments (order_id, method, amount, payment_date, status) VALUES
(1, 'Bkash', 5700.00, '2026-10-01 14:30:00', 'Completed'),
(2, 'Card', 8500.00, '2026-10-05 11:15:00', 'Completed'),
(3, 'Cash on Delivery', 3500.00, '2026-10-07 18:45:00', 'Pending');


-- ============================================================================
-- PART C: SQL DML (Insert/Update/Delete)
-- ============================================================================

-- Question 5:
-- Insert a new vendor named "SmartTech Ltd.", with contact person Rahim Khan,
-- email rahim@smarttech.com, phone 017XXXXXXXX, address Dhaka, Bangladesh,
-- under the Basic plan.
INSERT INTO vendors (
    business_name,
    contact_person,
    email,
    phone,
    business_address,
    subscription_plan_id
)
VALUES (
    'SmartTech Ltd.',
    'Rahim Khan',
    'rahim@smarttech.com',
    '017XXXXXXXX',
    'Dhaka, Bangladesh',
    (SELECT id FROM subscription_plans WHERE name = 'Basic' LIMIT 1)
);

-- Question 6:
-- Insert a product called "Laptop" under the Electronics category,
-- price 75,000, stock 10, status active, belonging to SmartTech Ltd.
-- Step 1: Insert product into products table
INSERT INTO products (
    vendor_id,
    name,
    description,
    price,
    stock_quantity,
    status
)
VALUES (
    (SELECT id FROM vendors WHERE business_name = 'SmartTech Ltd.' LIMIT 1),
    'Laptop',
    'High performance core laptop',
    75000.00,
    10,
    'active'
);

-- Step 2: Associate product with Electronics category in junction table
INSERT INTO product_categories (product_id, category_id)
VALUES (
    (SELECT id FROM products WHERE name = 'Laptop' LIMIT 1),
    (SELECT id FROM categories WHERE name = 'Electronics' LIMIT 1)
);

-- Question 7:
-- Update the stock quantity of "Laptop" product to 15.
UPDATE products
SET stock_quantity = 15
WHERE name = 'Laptop';

-- Question 8:
-- Delete a customer whose email is "oldcustomer@gmail.com".
DELETE FROM customers
WHERE email = 'oldcustomer@gmail.com';


-- ============================================================================
-- PART D: SQL Queries (DQL)
-- ============================================================================

-- Question 9:
-- Write a query to display all vendors along with their subscription plan name and price.
SELECT 
    v.id AS vendor_id,
    v.business_name,
    v.contact_person,
    v.email,
    sp.name AS plan_name,
    sp.price AS plan_price
FROM vendors v
JOIN subscription_plans sp ON v.subscription_plan_id = sp.id
ORDER BY v.id;

-- Question 10:
-- Find all products under the category "Electronics" with their name, price,
-- and stock quantity.
SELECT 
    p.name AS product_name,
    p.price,
    p.stock_quantity
FROM products p
JOIN product_categories pc ON p.id = pc.product_id
JOIN categories c ON pc.category_id = c.id
WHERE c.name = 'Electronics'
ORDER BY p.name;

-- Question 11:
-- List all orders placed by customer "Karim Uddin", showing order_id, date,
-- total_amount, and status.
SELECT 
    o.id AS order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE c.name = 'Karim Uddin'
ORDER BY o.order_date DESC;

-- Question 12:
-- Show the payment details (method, amount, status) for order_id = 1.
SELECT 
    order_id,
    method,
    amount,
    status,
    payment_date
FROM payments
WHERE order_id = 1;

-- Question 13:
-- Find the top 5 best-selling products based on total quantity sold.
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_quantity_sold DESC
LIMIT 5;
