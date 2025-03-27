SELECT 
    s.name as Supplier,d.SerialNumber as Pos_Machine
   
  
FROM
    transaction t
    INNER JOIN supplier s ON t.SupplierId = s.Id
    inner join device d on d.SupplierId = s.Id
WHERE 
    
   d.SerialNumber  IN ('VS44205860467'
   
)
GROUP BY 
    s.name
