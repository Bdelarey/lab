WITH coll AS (
    SELECT 
        "productName",
        SUM("loanAmount") AS "TotalLoanAmount",
        SUM(
            CASE 
                WHEN state = 'ACTIVE_IN_ARREARS' 
                     AND CAST(loan_account.data->'disbursementDetails'->>'disbursementDate' AS DATE) - INTERVAL '1 month' <= CURRENT_DATE
                THEN "loanAmount"
                ELSE 0
            END
        ) AS "VAR 30",
        SUM(
            CASE 
                WHEN state = 'ACTIVE_IN_ARREARS' 
                     AND CAST(loan_account.data->'disbursementDetails'->>'disbursementDate' AS DATE) < CURRENT_DATE - INTERVAL '1 day'
                THEN "loanAmount"
                ELSE 0
            END
        ) AS "VAR FROM YESTERDAY",
        SUM(
            CASE 
                WHEN state = 'ACTIVE_IN_ARREARS' 
                     AND CAST(loan_account.data->'disbursementDetails'->>'disbursementDate' AS DATE) 
                         <= date_trunc('month', CURRENT_DATE) 
                THEN "loanAmount"
                ELSE 0
            END
        ) AS "VAR FROM BEGINNING OF MONTH"
    FROM 
        loan_account 
    WHERE 
        state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
    GROUP BY 
        "productName"
    ORDER BY 
        "productName" ASC
)
SELECT 
    "productName",
    "TotalLoanAmount",
    "VAR 30",
    ROUND(("VAR 30"::NUMERIC / "TotalLoanAmount"::NUMERIC) * 100, 2) AS "PAR 30",
    "VAR FROM YESTERDAY",
    "VAR FROM BEGINNING OF MONTH"
FROM 
    coll;
