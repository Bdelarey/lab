
select *


FROM 
    product.product_definition pd
INNER JOIN 
    product.product_definition_tenant pdt ON pd."Id" = pdt."productDefinitionId"
INNER JOIN 
    mambu.mambu_tenant mt ON pdt."tenantId" = mt."tenantId"
INNER JOIN 
    mambu.branch b ON b."tenantId" = mt."tenantId"
INNER JOIN 
    product.account a ON a."productDefinitionId" = pd."Id"
INNER JOIN 
    client."account" ca ON ca."Id" = a."clientAccountId"
INNER JOIN 
    product.loan_account la ON a."Id" = la."accountId"
INNER JOIN 
    product.installment i ON a."Id" = i."accountId"
inner join 
    product.account_transaction at on at."accountId" = a."Id" 
inner join 
    product."transaction" t on  at."Id" = t."Id"   
    
where mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea'  and a.state = 'ACTIVE' and t.type = 'REPAYMENT' 