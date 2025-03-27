SELECT 
    t."name",
    SUM(la."principalBalance") AS "BOOK_SIZE",
    SUM(CASE 
            WHEN la."daysLate" >= 30 THEN la."principalBalance"
            ELSE 0
        END) AS "VAR 30",
    ROUND(
        CASE 
            WHEN SUM(la."principalBalance") > 0 
            THEN (SUM(CASE 
                        WHEN la."daysLate" >= 30 
                        THEN la."principalBalance" 
                        ELSE 0 
                    END) * 100.0) 
                 / SUM(la."principalBalance") 
            ELSE 0
        END, 2
    ) AS "PAR 30"
FROM master.tenant t
INNER JOIN product.product_definition_tenant pdt 
    ON t."parentId" = pdt."tenantId"
INNER JOIN product.account pa 
    ON pdt."productDefinitionId" = pa."productDefinitionId"
INNER JOIN product.loan_account la 
    ON la."accountId" = pa."Id"
WHERE pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
and pdt."tenantId" IN (
    SELECT "Id" 
    FROM public.gettenantdescendents('12fb9ca2-9ea2-4110-a6f9-0bd86e16beea')
)-- Early filtering
GROUP BY t."name"
HAVING SUM(la."principalBalance") > 0  -- Ensuring non-zero book size
ORDER BY "BOOK_SIZE" DESC  -- Optional sorting
LIMIT 100;
