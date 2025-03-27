SELECT 
    mt."name" as "tenant_name",  b."name" as "branch_name",
    a."name" as "product_name",
    SUM(CASE 
        WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE 0
    END) AS "BOOK_SIZE",
    SUM(CASE 
        WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        AND la."daysLate" >= 30
        THEN la."principalBalance"
        ELSE 0
    END) AS "VAR 30",
    CASE 
        WHEN SUM(CASE 
                    WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    THEN la."principalBalance"
                    ELSE 0
                END) > 0
        THEN ROUND(
            (SUM(CASE 
                    WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    AND la."daysLate" >= 30
                    THEN la."principalBalance"
                    ELSE 0
                END) * 100.0) 
            / SUM(CASE 
                    WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    THEN la."principalBalance"
                    ELSE 0
                END), 
            2
        )
        ELSE 0
    END AS "PAR 30"
from product.product_definition pd
inner join 
product.product_definition_tenant pdt on pd."Id" = pdt."productDefinitionId"

inner join 
mambu.mambu_tenant mt on pdt."tenantId"  = mt."tenantId"
inner join mambu.branch b on b."tenantId" = mt."tenantId"
inner join product.account a on a."productDefinitionId" = pd."Id"
inner join product.loan_account la on a."Id" = la."accountId" 
where mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea'
GROUP BY  mt."name", a."name", b."name"
HAVING SUM(CASE 
        WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE 0
    END) > 0
order by mt."name" asc, b."name" asc, a."name" asc