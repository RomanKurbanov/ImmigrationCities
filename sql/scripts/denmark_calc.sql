SELECT
    city_name,
    MAX(N1) + SUM(N2) + SUM(N3) AS tax_owed,
    :salary - (MAX(N1) + SUM(N2) + SUM(N3)) AS net_salary
FROM (
    SELECT
        city.name AS city_name,
        step1.N1,
        MUNICIPAL_TAX.tax_owed AS N2,
        FEDERAL_TAX.tax_owed AS N3
    FROM (
        -- Шаг 1: расчёт налога рынка труда (N1) и дохода после него (A1)
        SELECT
            (:salary - N1) AS A1,
            N1
        FROM (
            SELECT SUM(N1) AS N1
            FROM (
                SELECT LEAST(COALESCE(tax_limit, 999999999), (:salary * (percent_from / 100.0))) AS N1
                FROM tax
                WHERE jurisdiction = 'social'
                  AND country_id = (SELECT id FROM country WHERE name = 'Denmark')
            ) AS social_taxes
        ) AS social_sum
    ) AS step1

    -- Шаг 2: фиксированный вычет (C = 54 100 DKK)
    LEFT JOIN LATERAL (
        SELECT fixed_deduction AS C
        FROM deduction
        WHERE country_id = (SELECT id FROM country WHERE name = 'Denmark')
          AND deduction_type = 'personal'      -- или 'personal', если вычет хранится под этим типом
        ORDER BY deduction_from
        LIMIT 1
    ) AS FIXED_DED ON TRUE

    -- Привязка к географии: страна → провинция → город
    JOIN country ON country.id = (SELECT id FROM country WHERE name = 'Denmark')
    JOIN province ON province.country_id = country.id
    JOIN city ON city.province_id = province.id

    -- Шаг 3: муниципальный налог (N2) – зависит от города, применяется к A2
    LEFT JOIN LATERAL (
        SELECT SUM(
            LEAST(
                (LEAST(A2, UPPER_TAX.tax_from) - MUNI_TAX.tax_from)
                * (1.0 - COALESCE(MUNI_TAX.exempt_percent, 0) / 100.0),
                COALESCE(MUNI_TAX.tax_limit, 999999999)
            ) * (MUNI_TAX.percent_from / 100.0)
        ) AS tax_owed
        FROM tax AS MUNI_TAX
        LEFT JOIN LATERAL (
            SELECT tax_from
            FROM tax AS UPPER_TAX
            WHERE UPPER_TAX.country_id = MUNI_TAX.country_id
              AND (UPPER_TAX.province_id = MUNI_TAX.province_id OR (UPPER_TAX.province_id IS NULL AND MUNI_TAX.province_id IS NULL))
              AND (UPPER_TAX.city_id = MUNI_TAX.city_id OR (UPPER_TAX.city_id IS NULL AND MUNI_TAX.city_id IS NULL))
              AND UPPER_TAX.jurisdiction = MUNI_TAX.jurisdiction
              AND UPPER_TAX.tax_from > MUNI_TAX.tax_from
            ORDER BY UPPER_TAX.tax_from
            LIMIT 1
        ) AS UPPER_TAX ON TRUE,
        -- A2 – налогооблагаемая база после соцналога и фиксированного вычета
        LATERAL (SELECT step1.A1 - COALESCE(FIXED_DED.C, 0) AS A2) AS base
        WHERE MUNI_TAX.country_id = (SELECT id FROM country WHERE name = 'Denmark')
          AND MUNI_TAX.jurisdiction = 'city'
          AND (MUNI_TAX.city_id = city.id OR MUNI_TAX.city_id IS NULL)
          AND A2 > MUNI_TAX.tax_from
    ) AS MUNICIPAL_TAX ON TRUE

    -- Шаг 4: федеральный налог (N3) – прогрессивная шкала, применяется к A2
    LEFT JOIN LATERAL (
        SELECT SUM(
            LEAST(
                (LEAST(A2, UPPER_TAX.tax_from) - FED_TAX.tax_from)
                * (1.0 - COALESCE(FED_TAX.exempt_percent, 0) / 100.0),
                COALESCE(FED_TAX.tax_limit, 999999999)
            ) * (FED_TAX.percent_from / 100.0)
        ) AS tax_owed
        FROM tax AS FED_TAX
        LEFT JOIN LATERAL (
            SELECT tax_from
            FROM tax AS UPPER_TAX
            WHERE UPPER_TAX.country_id = FED_TAX.country_id
              AND (UPPER_TAX.province_id = FED_TAX.province_id OR (UPPER_TAX.province_id IS NULL AND FED_TAX.province_id IS NULL))
              AND (UPPER_TAX.city_id = FED_TAX.city_id OR (UPPER_TAX.city_id IS NULL AND FED_TAX.city_id IS NULL))
              AND UPPER_TAX.jurisdiction = FED_TAX.jurisdiction
              AND UPPER_TAX.tax_from > FED_TAX.tax_from
            ORDER BY UPPER_TAX.tax_from
            LIMIT 1
        ) AS UPPER_TAX ON TRUE,
        LATERAL (SELECT step1.A1 - COALESCE(FIXED_DED.C, 0) AS A2) AS base
        WHERE FED_TAX.country_id = (SELECT id FROM country WHERE name = 'Denmark')
          AND FED_TAX.jurisdiction = 'federal'
          AND A2 > FED_TAX.tax_from
    ) AS FEDERAL_TAX ON TRUE

) AS tax_calc
GROUP BY city_name;