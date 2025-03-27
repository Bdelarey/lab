SELECT 
    "activityType" as "ACTIVITY TYPE",
    ROUND(AVG(EXTRACT(EPOCH FROM "activityEndDate" - "activityStartDate") / 3600), 2) AS "ACTIVITY DURATION",
    date_trunc('month', "activityStartDate")::DATE as "MONTH"
FROM 
    reporting.agent_activity_report
WHERE 
    "activityStartDate" >= date_trunc('month', CURRENT_DATE - INTERVAL '6 months')
    AND "activityStartDate" < date_trunc('month', CURRENT_DATE)
GROUP BY 
    "activityType", "MONTH"
ORDER BY 
    "MONTH";

