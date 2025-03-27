select  la."accountId" as "Account_Number",sum(la."loanAmount") as "Loan_Amount",sum(I."amountDue") as "Installment_Due", sum(I."amountPaid") as "Installment_Paid"

from 


product.account a 
inner join 
client."account" ca on ca."Id" = a."clientAccountId" 
inner join 
product.loan_account la on a."Id" = la."accountId"
inner join 
--product.account_transaction at on a."Id" = at."accountId"
 product.installment i on a."Id" = i."accountId"
where la."accountId" = '8a938758-91a1-8758-0191-a7bfbcc37dfb'

group by la."accountId"