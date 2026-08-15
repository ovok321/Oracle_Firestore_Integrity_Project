/* ============================================================
   03_oracle_integrity_summary.sql
   ============================================================ */

SELECT
    COUNT(*) AS total_tests,
    SUM(CASE WHEN test_passed = 'YES' THEN 1 ELSE 0 END)
        AS tests_behaved_as_expected,
    ROUND(
        100 * SUM(CASE WHEN test_passed = 'YES' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS expected_behavior_percent
FROM flex_oracle_results;

SELECT
    COUNT(*) AS invalid_core_tests,
    SUM(CASE WHEN actual_outcome = 'REJECTED' THEN 1 ELSE 0 END)
        AS invalid_core_records_rejected,
    ROUND(
        100 * SUM(CASE WHEN actual_outcome = 'REJECTED' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS invalid_rejection_percent
FROM flex_oracle_results
WHERE test_no BETWEEN 2 AND 6;

SELECT
    COUNT(*) AS flexibility_tests,
    SUM(CASE WHEN actual_outcome = 'ACCEPTED' THEN 1 ELSE 0 END)
        AS accepted_without_schema_change
FROM flex_oracle_results
WHERE test_no IN (7,8);
