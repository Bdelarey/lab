

SELECT COUNT(
    CASE 
        WHEN la."daysLate" = 0 THEN 1
        ELSE NULL
    END
) as "Performing",
 sum(
    CASE 
        WHEN a."state" in ('ACTIVE','ACTIVE_IN_ARREARS')
        THEN la."principalBalance"
        ELSE NULL
    END
) as "Book Size"


 FROM product.account a
 inner join product.loan_account la on a."Id" = la."accountId"

/* Book Size:
•	This represents the total outstanding balance or value of the loan portfolio for the specific product.

 1. Performing
•	Definition: Loans that are being repaid on time, without any overdue payments. Borrowers are meeting their payment schedules as agreed upon in the loan terms.
*/