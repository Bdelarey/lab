SELECT 
    a."name",
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
FROM PRODUCT.loan_account la
INNER JOIN PRODUCT.account a
    ON la."accountId" = a."Id"
GROUP BY a."name"
HAVING SUM(CASE 
        WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE 0
    END) > 0;
    
    
    
    
   