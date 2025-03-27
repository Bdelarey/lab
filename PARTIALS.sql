	/*Definition: Loans where only partial payments have been made. Borrowers might be paying less
    than the full amount due, which could indicate potential financial difficulty.*/


with PARTIAL_COUNT as (SELECT 
    mt."name" AS "Tenant",
    la."accountId" AS "Account_Number",
    (la."loanAmount") AS "Loan_Amount",
    (i."amountDue") AS "Installment_Due",
    (i."amountPaid") AS "Installment_Paid",
    CASE 
        WHEN (i."amountPaid") < (i."amountDue") THEN 1
        ELSE 0 
    END AS "Partial_Payment"
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
WHERE 
    mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea' 
    AND a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
GROUP BY 
    la."accountId", mt."name",(i."amountPaid"), (i."amountDue"),(la."loanAmount") )
    
    select count(distinct("Account_Number"))
    
    
    
    from partial_count
    
    where "Partial_Payment" >= 1