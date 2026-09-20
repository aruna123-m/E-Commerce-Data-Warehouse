-- ============================================================
-- SOURCE DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS ecommerce_source;
USE ecommerce_source;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- STAGING DATABASE
-- ============================================================
CREATE DATABASE ecommerce_staging;
USE ecommerce_staging;

CREATE TABLE stg_customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE stg_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

CREATE TABLE stg_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE stg_products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE stg_sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

CREATE TABLE stg_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

CREATE TABLE stg_order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

CREATE TABLE stg_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

CREATE TABLE stg_category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- ------------------------------------------------------------
-- Load CSVs into staging (each file loaded once)
-- ------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/olist_customers_dataset.csv'
INTO TABLE stg_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/olist_orders_dataset.csv'
INTO TABLE stg_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/olist_order_items_dataset.csv'
INTO TABLE stg_order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/olist_products_dataset.csv'
INTO TABLE stg_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/olist_sellers_dataset.csv'
INTO TABLE stg_sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ELCOT/Desktop/ecommerce_project/raw_data/product_category_name_translation.csv'
INTO TABLE stg_category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- DATA WAREHOUSE (DW) DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS ecommerce_dw;
USE ecommerce_dw;

CREATE TABLE dim_customers (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(32),
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

INSERT INTO dim_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    MAX(customer_unique_id),
    MAX(customer_zip_code_prefix),
    MAX(customer_city),
    MAX(customer_state)
FROM ecommerce_staging.stg_customers
GROUP BY customer_id;

CREATE TABLE dim_products (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(32),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

INSERT INTO dim_products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM ecommerce_staging.stg_products;

CREATE TABLE dim_sellers (
    seller_key INT AUTO_INCREMENT PRIMARY KEY,
    seller_id VARCHAR(32),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

INSERT INTO dim_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM ecommerce_staging.stg_sellers;

CREATE TABLE dim_category (
    category_key INT AUTO_INCREMENT PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

INSERT INTO dim_category (
    product_category_name,
    product_category_name_english
)
SELECT
    product_category_name,
    product_category_name_english
FROM ecommerce_staging.stg_category_translation;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_name VARCHAR(20)
);

INSERT INTO dim_date
(date_key, full_date, year, quarter, month, month_name, day, day_name)
SELECT
    DATE_FORMAT(d, '%Y%m%d') + 0 AS date_key,
    d AS full_date,
    YEAR(d) AS year,
    QUARTER(d) AS quarter,
    MONTH(d) AS month,
    MONTHNAME(d) AS month_name,
    DAY(d) AS day,
    DAYNAME(d) AS day_name
FROM (
    SELECT
        DATE_ADD('2016-09-04', INTERVAL n DAY) AS d
    FROM (
        SELECT a.n + b.n * 10 + c.n * 1000 AS n
        FROM
            (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
             UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
            (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
             UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
            (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
             UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    ) numbers
    WHERE n <= DATEDIFF('2018-10-17', '2016-09-04')
) dates;

CREATE TABLE fact_orders (
    order_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(32),
    customer_key INT,
    order_status VARCHAR(30),
    order_purchase_date_key INT,
    order_approved_date_key INT,
    order_delivered_date_key INT,
    order_estimated_delivery_date_key INT
);

-- Final version: dedupes stg_orders per order_id and handles blank dates
INSERT INTO fact_orders (
    order_id,
    customer_key,
    order_status,
    order_purchase_date_key,
    order_approved_date_key,
    order_delivered_date_key,
    order_estimated_delivery_date_key
)
SELECT
    o.order_id,
    MAX(c.customer_key),
    MAX(o.order_status),
    MAX(DATE_FORMAT(STR_TO_DATE(NULLIF(o.order_purchase_timestamp, ''), '%d-%m-%Y %H:%i'), '%Y%m%d')),
    MAX(DATE_FORMAT(STR_TO_DATE(NULLIF(o.order_approved_at, ''), '%d-%m-%Y %H:%i'), '%Y%m%d')),
    MAX(DATE_FORMAT(STR_TO_DATE(NULLIF(o.order_delivered_customer_date, ''), '%d-%m-%Y %H:%i'), '%Y%m%d')),
    MAX(DATE_FORMAT(STR_TO_DATE(NULLIF(o.order_estimated_delivery_date, ''), '%d-%m-%Y %H:%i'), '%Y%m%d'))
FROM ecommerce_staging.stg_orders o
JOIN dim_customers c
    ON o.customer_id = c.customer_id
GROUP BY o.order_id;

-- fix customer_key mapping (handles any duplicate customer_id rows in staging)
CREATE TEMPORARY TABLE customer_key_map AS
SELECT
    o.order_id,
    c.customer_key AS new_customer_key
FROM (
    SELECT order_id, MAX(customer_id) AS customer_id
    FROM ecommerce_staging.stg_orders
    GROUP BY order_id
) o
JOIN dim_customers c
    ON o.customer_id = c.customer_id;

SET SQL_SAFE_UPDATES = 0;
UPDATE fact_orders fo
JOIN customer_key_map m
    ON fo.order_id = m.order_id
SET fo.customer_key = m.new_customer_key;

CREATE INDEX idx_fact_orders_order_id
ON fact_orders(order_id);

CREATE TABLE fact_order_items (
    order_item_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(32),
    order_item_id INT,
    customer_key INT,
    product_key INT,
    seller_key INT,
    order_purchase_date_key INT,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- Final version: dedupes stg_orders per order_id before joining
INSERT INTO fact_order_items (
    order_id,
    order_item_id,
    customer_key,
    product_key,
    seller_key,
    order_purchase_date_key,
    price,
    freight_value
)
SELECT
    oi.order_id,
    oi.order_item_id,
    c.customer_key,
    p.product_key,
    s.seller_key,
    DATE_FORMAT(STR_TO_DATE(o.order_purchase_timestamp, '%d-%m-%Y %H:%i'), '%Y%m%d'),
    oi.price,
    oi.freight_value
FROM ecommerce_staging.stg_order_items oi
JOIN (
    SELECT
        order_id,
        MAX(customer_id) AS customer_id,
        MAX(order_purchase_timestamp) AS order_purchase_timestamp
    FROM ecommerce_staging.stg_orders
    GROUP BY order_id
) o
    ON oi.order_id = o.order_id
JOIN dim_customers c
    ON o.customer_id = c.customer_id
JOIN dim_products p
    ON oi.product_id = p.product_id
JOIN dim_sellers s
    ON oi.seller_id = s.seller_id;

-- ============================================================
-- DATA MARTS
-- ============================================================
CREATE TABLE mart_sales AS
SELECT
    d.full_date,
    d.year,
    d.month_name,
    c.customer_state,
    COUNT(DISTINCT fo.order_id) AS total_orders,
    SUM(foi.price) AS total_revenue,
    SUM(foi.freight_value) AS total_freight,
    ROUND(AVG(foi.price), 2) AS avg_item_price
FROM fact_orders fo
JOIN fact_order_items foi
    ON fo.order_id = foi.order_id
JOIN dim_customers c
    ON fo.customer_key = c.customer_key
JOIN dim_date d
    ON fo.order_purchase_date_key = d.date_key
GROUP BY
    d.full_date,
    d.year,
    d.month_name,
    c.customer_state;

CREATE TABLE mart_category AS
SELECT
    p.product_category_name,
    c.product_category_name_english,
    COUNT(foi.order_id) AS times_sold,
    SUM(foi.price) AS total_revenue,
    ROUND(AVG(foi.price), 2) AS avg_price
FROM fact_order_items foi
JOIN dim_products p
    ON foi.product_key = p.product_key
LEFT JOIN dim_category c
    ON p.product_category_name = c.product_category_name
GROUP BY
    p.product_category_name,
    c.product_category_name_english;

-- ============================================================
-- VALIDATION / REPORTING QUERIES
-- ============================================================
SELECT COUNT(*) AS customers FROM dim_customers;
SELECT COUNT(*) AS products FROM dim_products;
SELECT COUNT(*) AS sellers FROM dim_sellers;
SELECT COUNT(*) AS categories FROM dim_category;
SELECT COUNT(*) AS dates FROM dim_date;
SELECT COUNT(*) AS orders FROM fact_orders;
SELECT COUNT(*) AS order_items FROM fact_order_items;

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
LIMIT 10;

SELECT
    year,
    SUM(total_revenue) AS total_revenue
FROM mart_sales
GROUP BY year
ORDER BY year;

SELECT
    product_category_name_english,
    times_sold,
    total_revenue
FROM mart_category
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    customer_state,
    SUM(total_revenue) AS total_revenue
FROM mart_sales
GROUP BY customer_state
ORDER BY total_revenue DESC
LIMIT 10;

SHOW TABLES;

SHOW DATABASES;

USE ecommerce_staging;

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM stg_customers
UNION ALL
SELECT 'orders', COUNT(*) FROM stg_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM stg_order_items
UNION ALL
SELECT 'products', COUNT(*) FROM stg_products
UNION ALL
SELECT 'sellers', COUNT(*) FROM stg_sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM stg_category_translation;

SELECT COUNT(*) FROM stg_customers;
SELECT COUNT(*) FROM stg_orders;
SELECT COUNT(*) FROM stg_category_translation;

USE ecommerce_dw;
SHOW TABLES;

SELECT COUNT(*) AS fact_orders FROM fact_orders;
SELECT COUNT(*) AS fact_order_items FROM fact_order_items;
SELECT COUNT(*) AS mart_sales FROM mart_sales;
SELECT COUNT(*) AS mart_category FROM mart_category;

SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;