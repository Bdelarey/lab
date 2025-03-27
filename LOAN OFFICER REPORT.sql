SELECT *
FROM (
    SELECT 
        SUBSTRING("agentRole", 3, LENGTH("agentRole") - 4) AS "agentRoles",
        "regionName"
    FROM 
        reporting.agent_activity_report
) subquery
WHERE "agentRoles" in ('Loan Officer','Team Leader') and "regionName" like 'stock%'
