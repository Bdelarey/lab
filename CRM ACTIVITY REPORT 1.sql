select role.name as "role",count("user"."Id") as "User",count(sales.activity_assignment."userId") as assigned_user,count("sales"."activity"."Id") as "activity"
,sales.activity_assignment."status",lat,lng

from 
master.user 
inner join sales.activity on "user"."Id" = sales.activity."createdUserId" 
inner join user_role on "user"."Id"  = "user_role"."userId"  
inner join role on role."Id"   ="user_role"."roleId" 
inner join sales.activity_assignment on sales.activity."Id" =sales.activity_assignment."activityId" 
where role.name in ('Team Leader','Loan Officer')

group by role.name,status,lat,lng

order by lat desc