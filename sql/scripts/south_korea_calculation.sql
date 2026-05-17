SELECT
    city_name ,
    MAX(N1) + SUM(N2) AS tax_owed,
    :salary - (MAX(N1) + SUM(N2)) AS net_salary
FROM (
    SELECT 
        city.name AS city_name,
        N1,
        FEDERAL_TAX_BRACKET.tax_owed AS N2
    FROM (
        -- Шаг 1: социальный налог (N1) и доход после него (A1)
        SELECT 
            (:salary - N1) AS A1,
            N1
        FROM (
            SELECT SUM(N1) AS N1
            FROM (
                SELECT LEAST(tax_limit, (:salary * (percent_from / 100.0))) AS N1
                FROM tax
                WHERE jurisdiction = 'social'
                  AND country_id = (SELECT id FROM country WHERE name = 'South Korea')
            ) AS social_taxes
        ) AS social_sum
    ) AS step1

    -- Шаг 2: профессиональный вычет (C)
    LEFT JOIN LATERAL (
        SELECT 
            (A1 * (deduction_rate / 100.0)) + fixed_deduction AS professional_deduction
        FROM deduction
        WHERE deduction.country_id = (SELECT id FROM country WHERE name = 'South Korea')
          AND deduction.deduction_type = 'professional'
          AND deduction.deduction_from <= :salary
        ORDER BY deduction.deduction_from
        LIMIT 1
    ) AS PROF_DED_BRACKET ON TRUE

    -- Шаг 3: личный вычет (D), фиксированный 1 500 000 KRW
    LEFT JOIN LATERAL (
        SELECT fixed_deduction AS personal_deduction
        FROM deduction
        WHERE deduction.country_id = (SELECT id FROM country WHERE name = 'South Korea')
          AND deduction.deduction_type = 'personal'
        ORDER BY deduction.deduction_from
        LIMIT 1
    ) AS PERSONAL_DED_BRACKET ON TRUE

    -- Шаг 4: федеральный подоходный налог (N2) – прогрессивная шкала,
    -- уже включает местный налог (10% надбавка) в хранимых ставках
    LEFT JOIN LATERAL (
        SELECT SUM(
            LEAST(
                (LEAST(:salary, UPPER_TAX_BRACKET.tax_from) - TAX_BRACKET.tax_from) 
                * (1.0 - COALESCE(TAX_BRACKET.exempt_percent, 0) / 100.0),
                COALESCE(TAX_BRACKET.tax_limit, 999999999999)
            ) * (TAX_BRACKET.percent_from / 100.0)
        ) AS tax_owed
        FROM tax AS TAX_BRACKET
        LEFT JOIN LATERAL (
            SELECT tax_from
            FROM tax AS UPPER_TAX
            WHERE UPPER_TAX.country_id = TAX_BRACKET.country_id
              AND (UPPER_TAX.province_id = TAX_BRACKET.province_id OR (UPPER_TAX.province_id IS NULL AND TAX_BRACKET.province_id IS NULL))
              AND (UPPER_TAX.city_id = TAX_BRACKET.city_id OR (UPPER_TAX.city_id IS NULL AND TAX_BRACKET.city_id IS NULL))
              AND UPPER_TAX.jurisdiction = TAX_BRACKET.jurisdiction
              AND UPPER_TAX.tax_from > TAX_BRACKET.tax_from
            ORDER BY UPPER_TAX.tax_from
            LIMIT 1
        ) AS UPPER_TAX_BRACKET ON TRUE
        WHERE TAX_BRACKET.country_id = (SELECT id FROM country WHERE name = 'South Korea')
          AND TAX_BRACKET.jurisdiction = 'federal'
          -- Применяем порог, только если налоговая база больше нижней границы порога
          AND (:salary - COALESCE(PROF_DED_BRACKET.professional_deduction, 0) - COALESCE(PERSONAL_DED_BRACKET.personal_deduction, 0)) > TAX_BRACKET.tax_from
    ) AS FEDERAL_TAX_BRACKET ON TRUE

    JOIN country ON country.id = (SELECT id FROM country WHERE name = 'South Korea')
    JOIN province ON province.country_id = country.id
    JOIN city ON city.province_id = province.id

    ORDER BY city_name
) AS tax_calc
GROUP BY city_name;