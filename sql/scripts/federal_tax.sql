SELECT TAX_BRACKET.id,
       TAX_BRACKET.jurisdiction,
       TAX_BRACKET.percent_from,
       TAX_BRACKET.tax_from,
       TAX_BRACKET.country_id,
       UPPER_TAX_BRACKET.tax_from AS tax_to
FROM TAX AS TAX_BRACKET
         LEFT JOIN LATERAL (SELECT *
                            FROM TAX UPPER_TAX
                            WHERE UPPER_TAX.country_id = TAX_BRACKET.country_id
                              AND UPPER_TAX.jurisdiction = TAX_BRACKET.jurisdiction
                              AND UPPER_TAX.tax_from > TAX_BRACKET.tax_from
                            ORDER BY UPPER_TAX.tax_from
    LIMIT 1) AS UPPER_TAX_BRACKET
ON TRUE
WHERE TAX_BRACKET.jurisdiction = 'federal'
ORDER BY TAX_BRACKET.country_id, TAX_BRACKET.jurisdiction, TAX_BRACKET.tax_from;