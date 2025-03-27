WITH months AS (
    SELECT 1 AS month
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
    UNION ALL SELECT 7
    UNION ALL SELECT 8
    UNION ALL SELECT 9
    UNION ALL SELECT 10
    UNION ALL SELECT 11
    UNION ALL SELECT 12
),
supplier_transactions AS (
    SELECT 
        supplier.name AS SupplierName,
        EXTRACT(MONTH FROM transaction.DateCreated) AS month,
        SUM(transaction.Amount) AS MonthlyPurchases,
        COUNT(transaction.Id) AS TransactionCount -- Count transactions
    FROM 
        supplier
    LEFT JOIN 
        transaction ON supplier.Id = transaction.SupplierId
        AND transaction.type = '1' 
        AND EXTRACT(YEAR FROM transaction.DateCreated) = 2024
    WHERE 
        supplier.name LIKE 'makro%' OR supplier.name LIKE 'mass%' OR supplier.name LIKE 'jum%'
    GROUP BY 
        supplier.name, 
        EXTRACT(MONTH FROM transaction.DateCreated)
),
all_months AS (
    SELECT 
        DISTINCT supplier.name AS SupplierName, 
        m.month
    FROM 
        supplier
    CROSS JOIN 
        months m -- Combine all suppliers with all months
    WHERE 
        supplier.name LIKE 'makro%' OR supplier.name LIKE 'mass%' OR supplier.name LIKE 'jum%'
)
SELECT 
    am.SupplierName,
    am.month,
    COALESCE(st.MonthlyPurchases, 0) AS MonthlyPurchases, -- Default to 0 if no transactions
    COALESCE(st.TransactionCount, 0) AS TransactionCount, -- Default to 0 if no transactions
    SUM(COALESCE(st.MonthlyPurchases, 0)) OVER (PARTITION BY am.SupplierName) AS YearPurchases, -- Total purchases for the year
    SUM(COALESCE(st.TransactionCount, 0)) OVER (PARTITION BY am.SupplierName) AS YearTransactionCount -- Total transactions for the year
FROM 
    all_months am
LEFT JOIN 
    supplier_transactions st 
    ON am.SupplierName = st.SupplierName AND am.month = st.month
ORDER BY 
    am.SupplierName, 
    am.month;
