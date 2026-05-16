SELECT CITY_NAME,
       MAX(N1) + SUM(N2) + MAX(N3) AS TAX_OWED,
       :salary - (MAX(N1) + SUM(N2) + MAX(N3)) AS NET_SALARY
FROM
    (SELECT city.name AS CITY_NAME,
            N1,
            A1,
            FEDERAL_TAX_BRACKET.tax_owed AS N2,
            ((:salary - N1)- ((A1 * (PROFESSIONAL_DEDUCTION_BRACKET.deduction_rate / 100)) + PROFESSIONAL_DEDUCTION_BRACKET.fixed_deduction) - LOCAL_DEDUCTION_BRACKET.fixed_deduction) * (PROVINCE_TAX_BRACKET.percent_from / 100) + 5000 AS N3

     FROM (SELECT N1,
                  (:salary - N1) AS A1
           FROM (SELECT SUM(N1) AS N1
                 FROM (SELECT LEAST(tax_limit, (:salary * (percent_from / 100))) AS N1
                       FROM tax
                       WHERE jurisdiction = 'social'
                         AND country_id = (SELECT ID FROM country WHERE name = 'Japan')) as N) as t) AS SUBQUERY
              LEFT JOIN LATERAL (SELECT *
                                 FROM DEDUCTION
                                 WHERE DEDUCTION.country_id = (SELECT ID FROM country WHERE name = 'Japan')
                                   AND DEDUCTION.deduction_type = 'professional'
                                   AND DEDUCTION.deduction_from <= :salary
                                 ORDER BY DEDUCTION.deduction_from
                                 LIMIT 1) AS PROFESSIONAL_DEDUCTION_BRACKET
                        ON TRUE
              LEFT JOIN LATERAL (SELECT *
                                 FROM DEDUCTION
                                 WHERE DEDUCTION.country_id = (SELECT ID FROM country WHERE name = 'Japan')
                                   AND DEDUCTION.deduction_type = 'local'
                                   AND DEDUCTION.deduction_from <= :salary
                                 ORDER BY DEDUCTION.deduction_from
                                 LIMIT 1) AS LOCAL_DEDUCTION_BRACKET
                        ON TRUE
              LEFT JOIN LATERAL (SELECT *
                                 FROM DEDUCTION
                                 WHERE DEDUCTION.country_id = (SELECT ID FROM country WHERE name = 'Japan')
                                   AND DEDUCTION.deduction_type = 'personal'
                                   AND DEDUCTION.deduction_from <= :salary
                                 ORDER BY DEDUCTION.deduction_from
                                 LIMIT 1) AS FIXED_DEDUCTION_BRACKET
                        ON TRUE
              LEFT JOIN LATERAL (SELECT *
                                 FROM TAX
                                 WHERE TAX.country_id = (SELECT ID FROM country WHERE name = 'Japan')
                                   AND TAX.jurisdiction = 'province'
                                 ORDER BY TAX.tax_from
                                 LIMIT 1) AS PROVINCE_TAX_BRACKET
                        ON TRUE
              LEFT JOIN LATERAL (SELECT LEAST((LEAST(:salary, UPPER_TAX_BRACKET.tax_from) - TAX_BRACKET.tax_from) * (1 - (coalesce(TAX_BRACKET.exempt_percent, 0) / 100)) * (TAX_BRACKET.percent_from / 100) ,
                                              TAX_BRACKET.tax_limit)  AS tax_owed

                                 FROM TAX AS TAX_BRACKET
                                          LEFT JOIN LATERAL (SELECT *
                                                             FROM TAX UPPER_TAX
                                                             WHERE UPPER_TAX.country_id = TAX_BRACKET.country_id
                                                               AND (UPPER_TAX.province_id = TAX_BRACKET.province_id OR
                                                                    (UPPER_TAX.province_id IS NULL AND TAX_BRACKET.province_id IS NULL))
                                                               AND (UPPER_TAX.city_id = TAX_BRACKET.city_id OR
                                                                    (UPPER_TAX.city_id IS NULL AND TAX_BRACKET.city_id IS NULL))
                                                               AND UPPER_TAX.jurisdiction = TAX_BRACKET.jurisdiction
                                                               AND UPPER_TAX.tax_from > TAX_BRACKET.tax_from
                                                             ORDER BY UPPER_TAX.tax_from
                                                             LIMIT 1) AS UPPER_TAX_BRACKET
                                                    ON TRUE
                                 WHERE TAX_BRACKET.country_id = (SELECT ID FROM country WHERE name = 'Japan')
                                   AND TAX_BRACKET.jurisdiction = 'federal'
                                   AND TAX_BRACKET.tax_from < (((:salary - N1 )- ((A1 * (PROFESSIONAL_DEDUCTION_BRACKET.deduction_rate / 100)) + PROFESSIONAL_DEDUCTION_BRACKET.fixed_deduction) - FIXED_DEDUCTION_BRACKET.fixed_deduction) * (1.0 - (coalesce(TAX_BRACKET.exempt_percent,0)/100)))
                                 ORDER BY TAX_BRACKET.country_id, TAX_BRACKET.province_id, TAX_BRACKET.city_id, TAX_BRACKET.jurisdiction,
                                          TAX_BRACKET.tax_from) AS FEDERAL_TAX_BRACKET
                        ON TRUE
              JOIN Country ON Country.id = (SELECT ID FROM country WHERE name = 'Japan')
              JOIN Province ON Province.country_id = Country.id
              JOIN city ON city.province_id = Province.id
     ORDER BY CITY_NAME) as SPDBLDBFDBPTBFTBCPc GROUP BY CITY_NAME;
