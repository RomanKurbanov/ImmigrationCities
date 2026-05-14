SELECT DEDUCTION_BRACKET.id,
       DEDUCTION_BRACKET.deduction_type,
       DEDUCTION_BRACKET.country_id,
       DEDUCTION_BRACKET.deduction_from,
       DEDUCTION_BRACKET.deduction_rate,
       DEDUCTION_BRACKET.fixed_deduction,
       DEDUCTION_BRACKET.currency,
       DEDUCTION_BRACKET.deduction_limit,
       UPPER_DEDUCTION_BRACKET.deduction_rate                                        AS tax_to,
       LEAST(:salary, UPPER_DEDUCTION_BRACKET.deduction_rate) - DEDUCTION_BRACKET.deduction_rate * (1 - (coalesce(DEDUCTION_BRACKET.exempt_percent, 0) / 100)) AS taxable_income,
       LEAST((LEAST(:salary, UPPER_DEDUCTION_BRACKET.deduction_rate) - DEDUCTION_BRACKET.deduction_rate) * (1 - (coalesce(DEDUCTION_BRACKET.exempt_percent, 0) / 100)) * (DEDUCTION_BRACKET.deduction_from / 100) ,
             DEDUCTION_BRACKET.tax_limit)                                      AS tax_owed

FROM TAX AS DEDUCTION_BRACKET
         JOIN Country ON Country.id = DEDUCTION_BRACKET.country_id
         JOIN Province ON Province.country_id = Country.id
         JOIN city ON city.province_id = Province.id
         LEFT JOIN LATERAL (SELECT *
                            FROM TAX UPPER_DEDUCTION
                            WHERE UPPER_DEDUCTION.country_id = DEDUCTION_BRACKET.country_id
                              AND (UPPER_DEDUCTION.province_id = DEDUCTION_BRACKET.province_id OR
                                   (UPPER_DEDUCTION.province_id IS NULL AND DEDUCTION_BRACKET.province_id IS NULL))
                              AND (UPPER_DEDUCTION.city_id = DEDUCTION_BRACKET.city_id OR
                                   (UPPER_DEDUCTION.city_id IS NULL AND DEDUCTION_BRACKET.city_id IS NULL))
                              AND UPPER_DEDUCTION.deduction_type = DEDUCTION_BRACKET.deduction_type
                              AND UPPER_DEDUCTION.deduction_rate > DEDUCTION_BRACKET.deduction_rate
                            ORDER BY UPPER_DEDUCTION.deduction_rate
                            LIMIT 1) AS UPPER_DEDUCTION_BRACKET
                   ON TRUE
WHERE city.name = :cityName
  AND (DEDUCTION_BRACKET.province_id = Province.id OR DEDUCTION_BRACKET.province_id IS NULL)
  AND (DEDUCTION_BRACKET.city_id = city.id OR DEDUCTION_BRACKET.city_id IS NULL)
  AND DEDUCTION_BRACKET.deduction_rate < (:salary * (1.0 - (coalesce(DEDUCTION_BRACKET.exempt_percent,0)/100)))
ORDER BY DEDUCTION_BRACKET.country_id, DEDUCTION_BRACKET.province_id, DEDUCTION_BRACKET.city_id, DEDUCTION_BRACKET.deduction_type,
         DEDUCTION_BRACKET.deduction_rate;
SELECT DEDUCTION_BRACKET.id,
       DEDUCTION_BRACKET.jurisdiction,
       DEDUCTION_BRACKET.country_id,
       DEDUCTION_BRACKET.province_id,
       DEDUCTION_BRACKET.city_id,
       DEDUCTION_BRACKET.percent_from,
       DEDUCTION_BRACKET.deduction_from,
       DEDUCTION_BRACKET.exempt_percent,
       UPPER_TAX_BRACKET.deduction_from                                                                                                            AS deduction_to,
       LEAST(:salary, UPPER_TAX_BRACKET.deduction_from) - DEDUCTION_BRACKET.deduction_from * (1 - (coalesce(DEDUCTION_BRACKET.exempt_percent, 0) / 100)) AS deductionable_income,
       LEAST((LEAST(:salary, UPPER_TAX_BRACKET.deduction_from) - DEDUCTION_BRACKET.deduction_from) * (1 - (coalesce(DEDUCTION_BRACKET.exempt_percent, 0) / 100)) * (DEDUCTION_BRACKET.percent_from / 100) ,
             DEDUCTION_BRACKET.deduction_limit)                                                                                                    AS deduction_owed
FROM DEDUCTION AS DEDUCTION_BRACKET
         JOIN Country ON Country.id = DEDUCTION_BRACKET.country_id
         LEFT JOIN LATERAL (SELECT *
                            FROM DEDUCTION UPPER_DEDUCTION
                            WHERE UPPER_DEDUCTION.country_id = DEDUCTION_BRACKET.country_id
                              AND UPPER_DEDUCTION.deduction_type = DEDUCTION_BRACKET.deduction_type
                              AND UPPER_DEDUCTION.deduction_from > DEDUCTION_BRACKET.deduction_from
                            ORDER BY UPPER_DEDUCTION.deduction_from
    LIMIT 1) AS UPPER_TAX_BRACKET
ON TRUE
WHERE city.name = :cityName
  AND (TAX_BRACKET.province_id = Province.id OR TAX_BRACKET.province_id IS NULL)
  AND (TAX_BRACKET.city_id = city.id OR TAX_BRACKET.city_id IS NULL)
  AND TAX_BRACKET.deduction_from < (:salary * (1.0 - (coalesce(TAX_BRACKET.exempt_percent,0)/100)))
ORDER BY TAX_BRACKET.country_id, TAX_BRACKET.province_id, TAX_BRACKET.city_id, TAX_BRACKET.jurisdiction,
    TAX_BRACKET.deduction_from;

