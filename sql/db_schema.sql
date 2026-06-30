-- =============================================


-- COFFEE SHOP SALES ANALYTICS - SQL Schema


-- =============================================


-- Developed by Ryadul Seam


-- =============================================

-- drop coffee_shop_sales table 

-- =============================================

drop table if exists coffee_shop_sales ;


-- =============================================


-- create coffee_shop_sales table 

CREATE TABLE coffee_shop_sales (
    transaction_id int PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_time TIME NOT NULL,
    transaction_qty INTEGER CHECK (transaction_qty > 0),
    store_id INTEGER NOT NULL,
    store_location TEXT,
    product_id INTEGER NOT NULL,
    unit_price NUMERIC(6,2) CHECK (unit_price >= 0),
    product_category TEXT,
    product_type TEXT,
    product_detail TEXT
);