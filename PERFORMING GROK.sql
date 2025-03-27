WITH PaidInstallments AS (
    SELECT 
        la."accountId",
        la."loanAmount",
        i."dueDate" as installment_due_date,
        i."amountDue" as installment_amount_due,
        i."amountPaid" as installment_amount_paid,
        at."datePosted" as payment_date,
        CASE 
            WHEN i."amountPaid" >= i."amountDue" 
                 AND at."datePosted" <= i."dueDate" 
            THEN 1 
            ELSE 0 
        END as paid_on_time_in_full
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
    INNER JOIN 
        product.account_transaction at ON at."accountId" = a."Id" 
    INNER JOIN 
        product."transaction" t ON at."Id" = t."Id"   
    WHERE 
        mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea' 
        AND a.state = 'ACTIVE' 
        AND t.type = 'REPAYMENT'
),
LoanPaymentStatus AS (
    SELECT 
        "accountId",
        "loanAmount",
        COUNT(*) as total_installments,
        SUM(paid_on_time_in_full) as on_time_installments
    FROM PaidInstallments
    GROUP BY "accountId", "loanAmount"
)
SELECT 
    COUNT(DISTINCT CASE 
        WHEN total_installments = on_time_installments 
        THEN "accountId" 
        END) as loans_paid_on_time_in_full,
    SUM(total_installments) as total_installments_all_loans,
    SUM(on_time_installments) as on_time_installments_all_loans
FROM LoanPaymentStatus;