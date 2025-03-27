select * 


from 

product.product_definition pd
inner join 
product.product_definition_tenant pdt on pd."Id" = pdt."productDefinitionId"

inner join 
mambu.mambu_tenant mt on pdt."tenantId"  = mt."tenantId"
inner join mambu.branch b on b."tenantId" = mt."tenantId"
inner join product.account a on a."productDefinitionId" = pd."Id"
inner join product.loan_account la on a."Id" = la."accountId" 
inner join client.account ca on ca."Id" = a."clientAccountId"
inner join client.account_assigned_user au on ca."Id" = au."accountId"
inner join master.user u on u."Id" = au."userId"
inner join master.user_role r on r."userId" = u."Id"
inner join master.role ur on ur."Id" = r."roleId"
where mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea'