SELECT 
    SUM(loan_calc) AS loan_total
FROM (
    SELECT DISTINCT 
        la."accountId",
        CASE 
            WHEN a.state IN ('ACTIVE', 'ACTIVE_IN_ARREARS', 'CLOSED') 
            THEN la."loanAmount"
        END AS loan_calc
    FROM product.product_definition pd
    INNER JOIN product.product_definition_tenant pdt 
        ON pd."Id" = pdt."productDefinitionId"
    INNER JOIN mambu.mambu_tenant mt 
        ON pdt."tenantId" = mt."tenantId"
    INNER JOIN product.account a 
        ON a."productDefinitionId" = pd."Id"
    INNER JOIN product.loan_account la 
        ON a."Id" = la."accountId"
    INNER JOIN accounting.currency cur 
        ON cur."Id" = pd."currencyId"
    INNER JOIN accounting.exchange_rate er 
        ON er."currencyId" = cur."Id"
    INNER JOIN accounting.tenant_currency tc 
        ON er."currencyId" = tc."currencyId"
    WHERE mt."tenantId" = '12fb9ca2-9ea2-4110-a6f9-0bd86e16beea' and la."dateCreated" > '2025-02-28'
) AS subquery
WHERE loan_calc IS NOT NULL;