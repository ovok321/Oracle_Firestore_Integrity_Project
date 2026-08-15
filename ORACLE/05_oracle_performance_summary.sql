/* ============================================================
   05_oracle_performance_summary.sql
   ============================================================ */

SELECT
    dataset_size,
    COUNT(*) AS runs,
    ROUND(AVG(elapsed_ms),2) AS average_elapsed_ms,
    MIN(elapsed_ms) AS minimum_elapsed_ms,
    MAX(elapsed_ms) AS maximum_elapsed_ms
FROM flex_oracle_perf_results
GROUP BY dataset_size
ORDER BY dataset_size;
