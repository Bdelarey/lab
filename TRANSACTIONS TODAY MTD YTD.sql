SELECT Name ,
    sum(
       case when transaction.DateCreated = curdate()
       then Amount
       else 0
       end ) as Transactions_TODAY,
      sum(
       case when month(transaction.DateCreated) = month(curdate())
       then Amount
       else 0
       end ) as Transactions_MTD,
        sum(
       case when month(transaction.DateCreated) <= year(curdate())
       then Amount
       else 0
       end ) as Transactions_YTD 
FROM 
    supplier
INNER JOIN 
    transaction ON supplier.Id = transaction.SupplierId
WHERE 
    transaction.type = '1' 
    AND EXTRACT(YEAR FROM transaction.DateCreated) = year(curdate())
    AND (supplier.name LIKE 'makro%' OR supplier.name LIKE 'mass%' or supplier.name like 'jumbo%')
    
 group by NAME   

    