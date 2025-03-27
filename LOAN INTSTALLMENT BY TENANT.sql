select mt."name" as "Tenant",b."name" as "Branch",la."accountId" as "Account_Number",sum(la."loanAmount") as "Loan_Amount"
from

product.product_definition pd
inner join 
product.product_definition_tenant pdt on pd."Id" = pdt."productDefinitionId"

inner join 
mambu.mambu_tenant mt on pdt."tenantId"  = mt."tenantId"
inner join mambu.branch b on b."tenantId" = mt."tenantId"
inner join product.account a on a."productDefinitionId" = pd."Id"

inner join 
client."account" ca on ca."Id" = a."clientAccountId" 
inner join 
product.loan_account la on a."Id" = la."accountId"
inner join 
product.account_transaction at on a."Id" = at."accountId"
inner join 
product.account_installment ai on  ai."accountId" = a."Id"
-- product.installment i on i."accountId" = a."Id"
where mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea' and
a.state in ('ACTIVE','CLOSED')
group by la."accountId",mt."name",b."name"

limit 100