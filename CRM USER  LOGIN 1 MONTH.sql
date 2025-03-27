select COUNT("Id")

from master."user"
left join master.log_in_attempt on master.log_in_attempt."userId" = master.user."Id" and master.log_in_attempt."dateCreated" in (select max(master.log_in_attempt."dateCreated") from master.log_in_attempt 
where (master.log_in_attempt."dateCreated" > (current_date -  interval '1 Month))limit 1 
where master."user"."Id" not in (select "itemId" from master.status where "itemType" = 'user' and "status" = 'DELETED')


