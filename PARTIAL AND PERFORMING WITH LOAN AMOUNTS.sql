WITH INST AS (
    SELECT 
        mt."name"                        AS "Tenant_Name",
        i."accountId"                    AS "Account_Number",
        SUM(i."amountDue")               AS "Amount_Due",
        SUM(i."amountPaid")              AS "amount_paid",
        i."dueDate",
        CASE 
            WHEN SUM(i."amountPaid") >= SUM(i."amountDue") THEN 1  -- Fully paid
            ELSE 0
        END                              AS "Paid",
        CASE 
            WHEN SUM(i."amountPaid") > 0 AND SUM(i."amountPaid") < SUM(i."amountDue") THEN 1
            ELSE 0
        END                              AS "Short_paid",
        CASE 
            WHEN SUM(i."amountDue") > 0 AND i."dueDate"::date > NOW() THEN 1
            ELSE 0
        END                              AS "To_Pay",
        CASE 
            WHEN SUM(i."amountPaid") >= SUM(i."amountDue") THEN la."principalBalance"  -- Fully paid
            ELSE 0
        END                              AS "loans_performing",
        CASE 
            WHEN SUM(i."amountPaid") > 0 AND SUM(i."amountPaid") < SUM(i."amountDue") THEN la."principalBalance"
            ELSE 0
        END                              AS "loans_partial"
    FROM product.product_definition      pd
        INNER JOIN product.product_definition_tenant pdt 
            ON pd."Id" = pdt."productDefinitionId"
        INNER JOIN mambu.mambu_tenant    mt 
            ON pdt."tenantId" = mt."tenantId"
        INNER JOIN product.account       a 
            ON a."productDefinitionId" = pd."Id"
        INNER JOIN product.loan_account  la 
            ON a."Id" = la."accountId"
        INNER JOIN product.installment   i 
            ON a."Id" = i."accountId"
    WHERE 
        mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea'
        AND a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS')
    GROUP BY
        mt."name",
        i."accountId", 
        i."dueDate",
        la."principalBalance"
),
inst_list AS (
    SELECT 
        "Tenant_Name",
        "Account_Number",
        SUM("Paid")                      AS "Loan_Performing",  -- Count of fully paid installments
        SUM("Short_paid")                AS "Loan_partial",     -- Count of partial payments
        loans_performing,
        loans_partial
    FROM INST
    GROUP BY 
        "Tenant_Name",
        "Account_Number",
        loans_performing,
        loans_partial
)
SELECT
    "Tenant_Name",
    COUNT(CASE WHEN "Loan_Performing" >= 1 THEN 1 END) AS "Performing",
    SUM(loans_performing)                              AS "Performing_Loans",
    COUNT(CASE WHEN "Loan_partial" >= 1 THEN 1 END)    AS "Partial",
    SUM(loans_partial)                                 AS "Partial_loans"
FROM inst_list
GROUP BY 
    "Tenant_Name";