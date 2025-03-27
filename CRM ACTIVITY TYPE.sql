SELECT 
    COUNT("activityId") as "ID",
    "activityType" as "ACTIVITY TYPE",
    date_trunc('month', "activityStartDate")::DATE as "MONTH"
FROM 
    reporting.agent_activity_report
WHERE 
    "activityStartDate" >= date_trunc('month', CURRENT_DATE - INTERVAL '12 months')
    AND "activityStartDate" < date_trunc('month', CURRENT_DATE)
GROUP BY 
    "activityType", 
    "MONTH"
ORDER BY 
    "MONTH";