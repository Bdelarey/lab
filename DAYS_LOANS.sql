SELECT CONCAT(client."firstName", ' ', client."lastName") 
       AS "Account Holder Name",
       client."idNumber" AS "Account Holder ID",
       loan_account."accountNumber" AS "Account ID",
       loan_account."loanAmount" AS "Loan Amount",
       loan_account."productName" AS "Product",
       (loan_account.data->'disbursementDetails'->>'disbursementDate')::date AS "Activation Date"
       
FROM client 
INNER JOIN loan_account 
    ON client."Id" = loan_account."clientId"
where  (loan_account.data->'disbursementDetails'->>'disbursementDate')::date = current_date
        and loan_account.state = 'ACTIVE'  and (loan_account.data->>'accountSubState' IS NULL)
