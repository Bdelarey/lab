select COUNT(*)

from master."user" where "Id" not in (select "itemId" from master.status where "itemType" = 'user' and "status" = 'DELETED')
