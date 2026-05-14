-- SELECT (N1) +
--        ((((:salary - (N1)) - total_professional_deduction) - fixed_deduction) * (total_income_tax / 100)) +
--        ((((:salary - (N1)) - total_professional_deduction) - total_local_deduction) * (total_local_tax_rate / 100) + 5000)
--     AS total_tax_owed
-- FROM (SELECT LEAST(B1_limit, (:salary * (B1 / 100))) + LEAST(B2_limit, (:salary * (B2 / 100))) AS N1,
--              NULL AS TOTAL_PROFESSIONAL_DEDUCTION,
--              NULL AS FIXED_DEDUCTION,
--              NULL AS total_income_tax,
--              NULL AS total_local_deduction,
--              NULL AS total_local_tax_rate) AS tax_calculation;
--
--
-- SELECT () AS N2 FROM
-- (SELECT LEAST(B1_limit, (:salary * (B1 / 100))) + LEAST(B2_limit, (:salary * (B2 / 100))) AS N1 FROM dual) AS tax_calculation;


SELECT SUM(7000000 - (SUM(N1) AS N1)
FROM (SELECT LEAST(tax_limit, (7000000 * (percent_from / 100))) AS N1
      FROM tax
      WHERE jurisdiction = 'social'
        AND country_id = (SELECT ID FROM country WHERE name = 'Japan')));

SELECT SUM(N1)
