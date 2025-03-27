SELECT s.name , count(distinct(c.IdNumber)),t.Amount
   
from client c
inner join transaction t on c.Id = t.ClientId
inner join supplier s on s.Id = t.SupplierId
    
   
 WHERE 
   
   (s.name LIKE 'makro%' OR s.name LIKE 'mass%' OR s.name LIKE 'jumbo%')
and t.DateCreated >= '2024-11-31' and t.type = 1
    
group by s.name