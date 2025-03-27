select "name",count("loanAmount") as count_loan_arrears

from branch b
inner join client c on b."Id" = c."assignedBranchId" 
inner join loan_account la on la."clientId" = c."Id"  

where la.state = ('ACTIVE_IN_ARREARS') 

group by "name"