select "agentRole","branchName",count("userId"),"activityLatitude","activityLongitude","actionLatitude","actionLongitude"

from reporting.agent_activity_report

where "agentRole" in ('{"Loan Officer"}','{"Team Leader"}')

group by "agentRole","branchName","activityLatitude","activityLongitude","actionLatitude","actionLongitude"