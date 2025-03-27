SELECT 
    s.name AS Supplier,
    d.SerialNumber AS Pos_Machine,
    COUNT(t.Amount) AS Transaction_Count,
    COALESCE(SUM(t.Amount), 0) AS Total_Amount, 
    EXTRACT(YEAR FROM COALESCE(t.DateCreated, CURRENT_DATE)) AS year,
    EXTRACT(MONTH FROM COALESCE(t.DateCreated, CURRENT_DATE)) AS month
FROM device d
INNER JOIN supplier s ON d.SupplierId = s.Id
LEFT JOIN transaction t ON t.SupplierId = s.Id 
    AND t.DeviceId = d.Id 
    AND t.type = 1
    AND t.DateCreated >= '2024-09-31'
GROUP BY 
    s.name, 
    d.SerialNumber, 
    year, 
    month;
