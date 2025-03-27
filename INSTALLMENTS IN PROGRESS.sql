SELECT 
    i."accountId" AS "Account_Number",
    SUM(i."amountDue") as "Amount_Due",
    SUM(i."amountPaid") as amount_paid,
    i."dueDate",
    CASE 
        WHEN (SUM(i."amountDue") = 0 AND SUM(i."amountPaid") > 0) THEN 1
        ELSE '0'
    END as "Paid",
    CASE 
        WHEN SUM(i."amountPaid") > 0 AND SUM(i."amountPaid") < SUM(i."amountDue") THEN 1
        ELSE '0'
    END as "Short_paid",
    CASE 
        WHEN (SUM(i."amountDue") > 0 AND i."dueDate"::date > NOW()) THEN 1
        ELSE '0'
    END as "To_Pay"
FROM 
    product.installment i
WHERE 
    i."accountId" = '8a938622-9521-cd50-0195-2301d76853d2'
GROUP BY 
    i."accountId", 
    i."dueDate"
ORDER BY 
    i."dueDate"