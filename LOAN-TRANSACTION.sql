select  la."accountId" as "Account_Number",sum(la."loanAmount")as "Loan_Amount", sum(at."principalAmount") as "Installment_Amount"

from product.account a 
inner join 
client."account" ca on ca."Id" = a."clientAccountId" 
inner join 
product.loan_account la on a."Id" = la."accountId"
inner join 
product.account_transaction at on a."Id" = at."accountId"

where la."accountId" = '8a938758-91a1-8758-0191-a7bfbcc37dfb'

group by la."accountId"