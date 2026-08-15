/* ============================================================
   01_create_oracle_schema.sql
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE flex_oracle_results PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE flex_products PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE flex_products (
    product_id NUMBER PRIMARY KEY,
    name       VARCHAR2(100) NOT NULL,
    category   VARCHAR2(50) NOT NULL,
    price      NUMBER(10,2) NOT NULL,
    stock      NUMBER NOT NULL,
    CONSTRAINT chk_flex_price CHECK (price >= 0),
    CONSTRAINT chk_flex_stock CHECK (stock >= 0 AND stock = TRUNC(stock))
);

CREATE TABLE flex_oracle_results (
    test_no            NUMBER PRIMARY KEY,
    test_name          VARCHAR2(100) NOT NULL,
    category           VARCHAR2(30) NOT NULL,
    expected_behavior  VARCHAR2(100) NOT NULL,
    actual_outcome     VARCHAR2(20) NOT NULL,
    test_passed        VARCHAR2(5) NOT NULL,
    database_message   VARCHAR2(1000)
);

SELECT table_name
FROM user_tables
WHERE table_name IN ('FLEX_PRODUCTS', 'FLEX_ORACLE_RESULTS')
ORDER BY table_name;
