SELECT 
    "productName", 
    
    -- Total Loans
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        THEN "principalBalance" 
        ELSE 0 
    END) AS "Total_Loans",

    -- PAR 30 (Loans in arrears for 30+ days)
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') AND CAST(data->>'daysLate' AS INT) >= 30     
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30",

    -- PAR 30 Percentage (Rounded to 2 decimal places)
    ROUND(
        SUM(CASE 
            WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') AND CAST(data->>'daysLate' AS INT) >= 30     
            THEN "principalBalance" 
            ELSE 0 
        END) / NULLIF(
            SUM(CASE 
                WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
                THEN "principalBalance" 
                ELSE 0 
            END), 0
        ), 2
    ) AS "PAR30_PERC"

FROM loan_account
GROUP BY "productName"
HAVING SUM(CASE 
            WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
            THEN "principalBalance" 
            ELSE 0 
          END) > 0  -- Only keep products where Total Loans > 0
ORDER BY "productName";
