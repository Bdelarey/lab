
with tenant_details AS (
       select tenant."Id",COALESCE(companydetails."name", '(No Company)') AS "company"
        FROM master.tenant
        left join master.tenant companydetails on companydetails."Id" = (select "Id" from  public.gettenantcompany(tenant."Id"::varchar) limit 1)
    )

SELECT COALESCE(tenant_details.company, '(No Company)') AS "company",
    "activityType" as "ACTIVITY TYPE",
    ROUND(AVG(EXTRACT(EPOCH FROM "activityEndDate" - "activityStartDate") / 3600), 2) AS "ACTIVITY DURATION",
    date_trunc('month', "activityStartDate")::DATE as "MONTH"
from reporting.agent_activity_report
        left join tenant_details on tenant_details."Id" = agent_activity_report."tenantId"
WHERE 
    "activityStartDate" >= date_trunc('month', CURRENT_DATE - INTERVAL '6 months')
    
GROUP BY 
    "company","activityType", "MONTH"
ORDER BY 
    "MONTH"