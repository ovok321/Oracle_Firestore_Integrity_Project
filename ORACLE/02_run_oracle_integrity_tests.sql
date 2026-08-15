/* ============================================================
   02_run_oracle_integrity_tests.sql
   Runs all 8 Oracle tests automatically.
   ============================================================ */

DELETE FROM flex_oracle_results;
DELETE FROM flex_products;
COMMIT;

/* T1 — Valid product: expected ACCEPT */
BEGIN
    INSERT INTO flex_products(product_id,name,category,price,stock)
    VALUES (1,'Standard Keyboard','Electronics',129.90,20);

    INSERT INTO flex_oracle_results
    VALUES (1,'Valid product','CORE INTEGRITY','ACCEPT',
            'ACCEPTED','YES','Valid product inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (1,'Valid product','CORE INTEGRITY','ACCEPT',
                'REJECTED','NO',SQLERRM);
END;
/

/* T2 — Missing required name: expected REJECT */
BEGIN
    INSERT INTO flex_products(product_id,name,category,price,stock)
    VALUES (2,NULL,'Electronics',99.90,10);

    INSERT INTO flex_oracle_results
    VALUES (2,'Missing required name','CORE INTEGRITY','REJECT',
            'ACCEPTED','NO','Invalid record unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (2,'Missing required name','CORE INTEGRITY','REJECT',
                'REJECTED','YES',SQLERRM);
END;
/

/* T3 — Negative price: expected REJECT */
BEGIN
    INSERT INTO flex_products(product_id,name,category,price,stock)
    VALUES (3,'Invalid Price Product','Test',-50,5);

    INSERT INTO flex_oracle_results
    VALUES (3,'Negative price','CORE INTEGRITY','REJECT',
            'ACCEPTED','NO','Invalid record unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (3,'Negative price','CORE INTEGRITY','REJECT',
                'REJECTED','YES',SQLERRM);
END;
/

/* T4 — Negative stock: expected REJECT */
BEGIN
    INSERT INTO flex_products(product_id,name,category,price,stock)
    VALUES (4,'Invalid Stock Product','Test',50,-2);

    INSERT INTO flex_oracle_results
    VALUES (4,'Negative stock','CORE INTEGRITY','REJECT',
            'ACCEPTED','NO','Invalid record unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (4,'Negative stock','CORE INTEGRITY','REJECT',
                'REJECTED','YES',SQLERRM);
END;
/

/* T5 — Wrong datatype for price: expected REJECT */
BEGIN
    EXECUTE IMMEDIATE q'[
        INSERT INTO flex_products(product_id,name,category,price,stock)
        VALUES (5,'Wrong Type Product','Test','FREE',5)
    ]';

    INSERT INTO flex_oracle_results
    VALUES (5,'Wrong datatype for price','CORE INTEGRITY','REJECT',
            'ACCEPTED','NO','Invalid record unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (5,'Wrong datatype for price','CORE INTEGRITY','REJECT',
                'REJECTED','YES',SQLERRM);
END;
/

/* T6 — Duplicate product identifier: expected REJECT */
BEGIN
    INSERT INTO flex_products(product_id,name,category,price,stock)
    VALUES (1,'Duplicate Product','Test',25,1);

    INSERT INTO flex_oracle_results
    VALUES (6,'Duplicate product identifier','CORE INTEGRITY','REJECT',
            'ACCEPTED','NO','Duplicate identifier unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (6,'Duplicate product identifier','CORE INTEGRITY','REJECT',
                'REJECTED','YES',SQLERRM);
END;
/

/* T7 — Extra laptop field RAM_GB: expected REJECT without schema change */
BEGIN
    EXECUTE IMMEDIATE q'[
        INSERT INTO flex_products(product_id,name,category,price,stock,ram_gb)
        VALUES (7,'Student Laptop','Laptop',2500,4,16)
    ]';

    INSERT INTO flex_oracle_results
    VALUES (7,'Add laptop-specific ram_gb field','SCHEMA FLEXIBILITY',
            'REJECT WITHOUT SCHEMA CHANGE','ACCEPTED','NO',
            'Extra field unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (7,'Add laptop-specific ram_gb field','SCHEMA FLEXIBILITY',
                'REJECT WITHOUT SCHEMA CHANGE','REJECTED','YES',SQLERRM);
END;
/

/* T8 — Different clothing structure: expected REJECT without schema change */
BEGIN
    EXECUTE IMMEDIATE q'[
        INSERT INTO flex_products
            (product_id,name,category,price,stock,size_label,material)
        VALUES
            (8,'Cotton Shirt','Clothing',79.90,30,'M','Cotton')
    ]';

    INSERT INTO flex_oracle_results
    VALUES (8,'Store different clothing structure','SCHEMA FLEXIBILITY',
            'REJECT WITHOUT SCHEMA CHANGE','ACCEPTED','NO',
            'Different structure unexpectedly accepted.');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO flex_oracle_results
        VALUES (8,'Store different clothing structure','SCHEMA FLEXIBILITY',
                'REJECT WITHOUT SCHEMA CHANGE','REJECTED','YES',SQLERRM);
END;
/

COMMIT;

SELECT test_no, test_name, category, expected_behavior,
       actual_outcome, test_passed, database_message
FROM flex_oracle_results
ORDER BY test_no;
