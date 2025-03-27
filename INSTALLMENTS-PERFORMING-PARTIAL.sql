WITH INST AS (
    SELECT 
        i."accountId" AS "Account_Number",
        SUM(i."amountDue") as "Amount_Due",
        SUM(i."amountPaid") as "amount_paid",
        i."dueDate",
        CASE 
            WHEN SUM(i."amountPaid") >= SUM(i."amountDue") THEN 1  -- Fully paid
            ELSE 0
        END as "Paid",
        CASE 
            WHEN SUM(i."amountPaid") > 0 AND SUM(i."amountPaid") < SUM(i."amountDue") THEN 1
            ELSE 0
        END as "Short_paid",
        CASE 
            WHEN SUM(i."amountDue") > 0 AND i."dueDate"::date > NOW() THEN 1
            ELSE 0
        END as "To_Pay"
    FROM product.product_definition pd
        INNER JOIN product.product_definition_tenant pdt 
            ON pd."Id" = pdt."productDefinitionId"
        INNER JOIN mambu.mambu_tenant mt 
            ON pdt."tenantId" = mt."tenantId"
        INNER JOIN product.account a 
            ON a."productDefinitionId" = pd."Id"
        INNER JOIN product.loan_account la 
            ON a."Id" = la."accountId"
        INNER JOIN product.installment i 
            ON a."Id" = i."accountId"
    WHERE 
        mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea'
        AND a.state in ('ACTIVE','ACTIVE_IN_ARREARS')
    GROUP BY 
        i."accountId", 
        i."dueDate"
),
inst_list AS (
    SELECT 
        "Account_Number",
        SUM("Paid") AS "Loan_Performing",  -- Count of fully paid installments
        SUM("Short_paid") AS "Loan_partial"  -- Count of partial payments
    FROM INST
    GROUP BY "Account_Number"
)
SELECT
    COUNT(CASE WHEN "Loan_Performing" >= 1 THEN 1 END) as "Performing",  -- Accounts with paid installments
    COUNT(CASE WHEN "Loan_partial" >= 1 THEN 1 END) as "Partial"  -- Accounts with partial payments
FROM inst_list;