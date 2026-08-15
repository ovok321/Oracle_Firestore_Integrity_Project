/* ============================================================
   04_oracle_performance_test.sql
   Supplementary small-scale write benchmark.
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE flex_oracle_perf_results PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE flex_product_perf PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE flex_product_perf (
    product_id NUMBER PRIMARY KEY,
    name       VARCHAR2(100) NOT NULL,
    category   VARCHAR2(50) NOT NULL,
    price      NUMBER(10,2) NOT NULL,
    stock      NUMBER NOT NULL,
    CONSTRAINT chk_flex_perf_price CHECK (price >= 0),
    CONSTRAINT chk_flex_perf_stock CHECK (stock >= 0 AND stock = TRUNC(stock))
);

CREATE TABLE flex_oracle_perf_results (
    dataset_size NUMBER NOT NULL,
    run_number   NUMBER NOT NULL,
    elapsed_ms   NUMBER(12,2) NOT NULL,
    tested_at    TIMESTAMP DEFAULT SYSTIMESTAMP
);

DECLARE
    v_start NUMBER;
    v_end   NUMBER;

    PROCEDURE run_test(p_size NUMBER, p_run NUMBER) IS
    BEGIN
        DELETE FROM flex_product_perf;
        COMMIT;

        v_start := DBMS_UTILITY.GET_TIME;

        FOR i IN 1 .. p_size LOOP
            INSERT INTO flex_product_perf(
                product_id, name, category, price, stock
            )
            VALUES (
                i,
                'Performance Product ' || i,
                CASE MOD(i,3)
                    WHEN 0 THEN 'Electronics'
                    WHEN 1 THEN 'Clothing'
                    ELSE 'Home'
                END,
                10 + MOD(i * 37, 10000) / 10,
                MOD(i,100)
            );
        END LOOP;

        COMMIT;
        v_end := DBMS_UTILITY.GET_TIME;

        INSERT INTO flex_oracle_perf_results(
            dataset_size, run_number, elapsed_ms
        )
        VALUES (
            p_size, p_run, (v_end - v_start) * 10
        );

        COMMIT;
    END;
BEGIN
    FOR r IN 1 .. 3 LOOP
        run_test(100, r);
    END LOOP;

    FOR r IN 1 .. 3 LOOP
        run_test(1000, r);
    END LOOP;
END;
/

SELECT dataset_size, run_number, elapsed_ms
FROM flex_oracle_perf_results
ORDER BY dataset_size, run_number;
