SELECT TAX_BRACKET.id,
       TAX_BRACKET.jurisdiction,
       TAX_BRACKET.country_id,
       TAX_BRACKET.province_id,
       TAX_BRACKET.city_id,
       TAX_BRACKET.percent_from,
       TAX_BRACKET.tax_from,
       UPPER_TAX_BRACKET.tax_from AS tax_to
FROM TAX AS TAX_BRACKET
         JOIN Country ON Country.id = TAX_BRACKET.country_id
         JOIN Province ON Province.country_id = Country.id
         JOIN Cities ON Cities.province_id = Province.id
         LEFT JOIN LATERAL (SELECT *
                            FROM TAX UPPER_TAX
                            WHERE UPPER_TAX.country_id = TAX_BRACKET.country_id
                              AND (UPPER_TAX.province_id = TAX_BRACKET.province_id OR (UPPER_TAX.province_id IS NULL AND TAX_BRACKET.province_id IS NULL))
                              AND (UPPER_TAX.city_id = TAX_BRACKET.city_id OR (UPPER_TAX.city_id IS NULL AND TAX_BRACKET.city_id IS NULL))
                              AND UPPER_TAX.jurisdiction = TAX_BRACKET.jurisdiction
                              AND UPPER_TAX.tax_from > TAX_BRACKET.tax_from
                            ORDER BY UPPER_TAX.tax_from
                            LIMIT 1) AS UPPER_TAX_BRACKET
                   ON TRUE
WHERE Cities.name = :cityName
AND (TAX_BRACKET.province_id = Province.id OR TAX_BRACKET.province_id IS NULL)
AND (TAX_BRACKET.city_id = Cities.id OR TAX_BRACKET.city_id IS NULL)
ORDER BY TAX_BRACKET.country_id, TAX_BRACKET.province_id, TAX_BRACKET.city_id, TAX_BRACKET.jurisdiction, TAX_BRACKET.tax_from;