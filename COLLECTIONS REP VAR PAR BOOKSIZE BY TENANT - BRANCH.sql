SELECT 
    t."name",
    SUM(CASE 
        WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE 0
    END) AS "BOOK_SIZE",
    SUM(CASE 
        WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        AND la."daysLate" >= 30
        THEN la."principalBalance"
        ELSE 0
    END) AS "VAR 30",
    CASE 
        WHEN SUM(CASE 
                    WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    THEN la."principalBalance"
                    ELSE 0
                END) > 0
        THEN ROUND(
            (SUM(CASE 
                    WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    AND la."daysLate" >= 30
                    THEN la."principalBalance"
                    ELSE 0
                END) * 100.0) 
            / SUM(CASE 
                    WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
                    THEN la."principalBalance"
                    ELSE 0
                END), 
            2
        )
        ELSE 0
    END AS "PAR 30"
FROM master.tenant t
inner join product.product_definition_tenant pdt on t."parentId" =  pdt."tenantId"
inner join product.account pa on pdt."productDefinitionId" = pa."productDefinitionId"
inner join product.loan_account la on la."accountId" = pa."Id"
GROUP BY t."name"
HAVING SUM(CASE 
        WHEN pa.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE 0
    END) > 0
    
    
    limit 100
    
    
    
    
   