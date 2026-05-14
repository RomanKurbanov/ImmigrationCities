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

