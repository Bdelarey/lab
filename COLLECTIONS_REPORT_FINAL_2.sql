SELECT 
    "productName",

    -- Total Loans (Current)
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        THEN "principalBalance" 
        ELSE 0 
    END) AS "Total_Loans",

    -- Total Loans at the Beginning of the Current Month
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->'disbursementDetails'->>'disbursementDate' AS DATE) <= DATE_TRUNC('month', CURRENT_DATE)  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "Total_Loans_Month_Start",

    -- Total Loans at the Beginning of the Current Year
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->'disbursementDetails'->>'disbursementDate' AS DATE) <= DATE_TRUNC('year', CURRENT_DATE)  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "Total_Loans_Year_Start",

    -- PAR 30 (Current)
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') AND CAST(data->>'daysLate' AS INT) >= 30     
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30_Current",

    -- PAR 30 at the Beginning of the Current Month
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->>'daysLate' AS INT) + DATE_PART('day', CURRENT_DATE) - 1 >= 30  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30_Month_Start",

    -- PAR 30 at the Beginning of the Year
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->>'daysLate' AS INT) + DATE_PART('doy', CURRENT_DATE) - 1 >= 30  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30_Year_Start",

    -- Difference from Month Start
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') AND CAST(data->>'daysLate' AS INT) >= 30     
        THEN "principalBalance" 
        ELSE 0 
    END) 
    - 
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->>'daysLate' AS INT) + DATE_PART('day', CURRENT_DATE) - 1 >= 30  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30_Diff_Month",

    -- Difference from Year Start
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') AND CAST(data->>'daysLate' AS INT) >= 30     
        THEN "principalBalance" 
        ELSE 0 
    END) 
    - 
    SUM(CASE 
        WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
        AND CAST(data->>'daysLate' AS INT) + DATE_PART('doy', CURRENT_DATE) - 1 >= 30  
        THEN "principalBalance" 
        ELSE 0 
    END) AS "PAR 30_Diff_Year",

    -- PAR 30 Ratio (PAR 30 / Total Loans)
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
    ) AS "PAR30_Divided_By_Total_Loans"

FROM loan_account
GROUP BY "productName"
HAVING SUM(CASE 
            WHEN state IN ('ACTIVE', 'ACTIVE_IN_ARREARS') 
            THEN "principalBalance" 
            ELSE 0 
          END) > 0  -- Only include products where Total_Loans > 0
ORDER BY "productName";
