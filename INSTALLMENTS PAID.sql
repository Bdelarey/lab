
SELECT 
    
    la."accountId" AS "Account_Number",
    la."principalBalance",
    (i."amountPaid") as amount_paid,
     i."amount",
    i."amountDue",
    (i."dueDate") ,
    at."datePosted" as loan_date
   
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
    product.loan_account la ON a."Id" = la."accountId"
INNER JOIN 
    product.installment i ON a."Id" = i."accountId"
inner join    
    product.account_transaction at on at."accountId" = a."Id"
WHERE 
    mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea' 
    AND a.state IN ('ACTIVE') and la."accountId" = '8a938622-9521-cd50-0195-2301d76853d2'
    
    GROUP BY 
   la."accountId","principalBalance",i."amountPaid",i."dueDate",  at."datePosted",i."amount",i."amountDue"
   
   order by  at."datePosted" 