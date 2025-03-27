select COUNT("activityId") as "ID","activityStatus" as "STATUS",date_trunc('month',"activityStartDate")::DATE as "MONTH" 

from reporting.agent_activity_report


WHERE 
    "activityStartDate" >= date_trunc('month', CURRENT_DATE - INTERVAL '12 months')
    AND "activityStartDate" < date_trunc('month', CURRENT_DATE)

group by "activityStatus","activityId","activityStartDate"

order by "MONTH"