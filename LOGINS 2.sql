With activity_status_changes as(
    SELECT DISTINCT master.status."Id" as "Id", "sales"."activity_assignment"."userId" as "userId", master.status."itemId", 'Status Update' as "itemType",
    CONCAT("sales"."activity".name, ' updated to ', "master"."status".status) as "description",'Status Changed' as "action",
    master.status."dateCreated", geo.user_position.latitude, geo.user_position.longitude,"master"."tenant"."lat" as "Tenant Latitude","master"."tenant"."lng" as "Tenant Longitude",
    geo.user_position.accuracy,
     geo.user_position."clientIp",
    "geo"."address"."address"
    FROM master.status
    join "sales"."activity_assignment" on master.status."itemId" = "sales"."activity_assignment"."Id" AND "master"."status"."itemType" = 'activityAssignment'
    join "sales"."activity" on sales.activity_assignment."activityId" = "sales"."activity"."Id"
    left join geo.user_position on geo.user_position."entityId" = master.status."Id" AND geo.user_position."entityType" = 'activityAssignment'
    left join geo.address on geo.address.longitude = geo.user_position.longitude AND geo.address.latitude = geo.user_position.latitude
    inner join master.tenant on "sales"."activity_assignment"."userId" = master.tenant."parentId" 
    WHERE (master.status."dateCreated"::date BETWEEN ('2024-11-01 00:00:00.000'::date) and ('2024-11-15 23:59:00.000'::date)) -- AND master.status.status != 'DELETED')
         and (master.status.status = 'Login' or master.status.status = 'Logout')
        group by master.status."Id", master.status."itemId", master.status."itemType", master.status."dateCreated",
        "sales"."activity_assignment"."userId","sales"."activity".name,"master"."status".status, geo.user_position.latitude, geo.user_position.longitude,
        geo.user_position.accuracy, geo.address."address", geo.user_position."clientIp",tenant.lat,tenant.lng
    ),
    comment_changes as (
        SELECT DISTINCT  master.comment."Id",  master.comment."userId", "itemId", 'Activity Comment' as "itemType",
        CASE WHEN (master.comment."isPrivate" = true) AND (master.comment."userId" != '94b16681-f011-44ff-9697-92decee082a3')  THEN '{Private Comment}' ELSE  master.comment.comment END as "description",
        'Commented' as "action",
        master.comment."dateCreated", geo.user_position.latitude, geo.user_position.longitude,tenant.lat,tenant.lng, geo.user_position.accuracy,
         geo.user_position."clientIp",
        "geo"."address"."address"
        FROM master.comment
        left join geo.user_position on geo.user_position."entityId" = master.comment."Id" AND geo.user_position."entityType" = 'comment'
        left join geo.address on geo.address.longitude = geo.user_position.longitude AND geo.address.latitude = geo.user_position.latitude
        inner join master.tenant on geo.user_position"."userId" = master.tenant."parentId"
        WHERE (master.comment."dateCreated"::date BETWEEN ('2024-11-01 00:00:00.000'::date) and ('2024-11-15 23:59:00.000'::date))
        group by  master.comment."Id", master.comment."dateCreated", master.comment."userId", "itemId", "itemType", geo.user_position.latitude,
        geo.user_position.longitude,  geo.user_position.accuracy, geo.address."address", geo.user_position."clientIp"
    ),
     assignment_team AS (
            SELECT ARRAY_AGG(DISTINCT COALESCE(sales.team."name", '(no team)')) AS "salesTeam"
            FROM sales.team
            LEFT JOIN sales.team_member ON sales.team_member."teamId" = sales.team."Id"
            WHERE sales."team_member"."userId"  IN (SELECT "userId" FROM activity_status_changes LIMIT 1)
        ),
    agent_actions as (
        SELECT DISTINCT  sales.agent_action."Id", sales.agent_action."userId", sales.agent_action."Id" as "itemId", 'Agent Activity' as "itemType",
                CASE
                    WHEN "sales"."agent_action"."action" = 0 THEN 'Agent stopped their day'
                    WHEN "sales"."agent_action"."action" = 1 THEN 'Agent started their day'
                    WHEN "sales"."agent_action"."action" = 2 THEN 'Agent uploaded a file'
                    WHEN "sales"."agent_action"."action" = 3 THEN 'Agent removed a file'
                    ELSE 'Unknown action'
                END as "description",
                CASE
                    WHEN "sales"."agent_action"."action" = 0 THEN 'Stopped'
                    WHEN "sales"."agent_action"."action" = 1 THEN 'Started'
                    WHEN "sales"."agent_action"."action" = 2 THEN 'Uploaded'
                    WHEN "sales"."agent_action"."action" = 3 THEN 'Removed'
                    ELSE 'Unknown action'
                END as "action",
                                sales.agent_action."dateCreated", geo.user_position.latitude, geo.user_position.longitude,tenant.lat,tenant.lng, geo.user_position.accuracy,
                geo.user_position."clientIp",
                "geo"."address"."address"
        FROM sales.agent_action
        LEFT join geo.user_position on geo.user_position."entityId" = sales.agent_action."Id" AND geo.user_position."entityType" = 'agentAction'
        left join geo.address on geo.address.longitude = geo.user_position.longitude AND geo.address.latitude = geo.user_position.latitude
         inner join master.tenant on geo.user_position"."userId" = master.tenant."parentId"
        WHERE (sales.agent_action."dateCreated"::date BETWEEN ('2024-11-01 00:00:00.000'::date) and ('2024-11-15 23:59:00.000'::date))
        group by  sales.agent_action."dateCreated", sales.agent_action."userId", sales.agent_action."Id", "itemType", geo.user_position.latitude, geo.user_position.longitude,geo.user_position.accuracy,
        geo.address."address", geo.user_position."clientIp"
    ),
    agent_log as (
        SELECT DISTINCT  geo.user_position."Id", geo.user_position."userId", geo.user_position."entityId" as "itemId", 'Agent Activity' as "itemType",
                            CASE WHEN geo.user_position."entityType" = 'login' THEN 'Agent Logged In' ELSE 'Agent Logged Out' END as "description",
                            CASE WHEN geo.user_position."entityType" = 'login' THEN 'Login' ELSE 'Logout' END as "action",
                            geo.user_position."dateCreated", geo.user_position.latitude, geo.user_position.longitude,tenant.lat,tenant.lng, geo.user_position.accuracy,
                            geo.user_position."clientIp",
                            "geo"."address"."address"
        from
        geo.user_position
        left join geo.address on geo.address.longitude = geo.user_position.longitude AND geo.address.latitude = geo.user_position.latitude
         inner join master.tenant on geo.user_position"."userId" = master.tenant."parentId"
        WHERE (geo.user_position."dateCreated"::date BETWEEN ('2024-11-01 00:00:00.000'::date)  and ('2024-11-15 23:59:00.000'::date)
                  and (geo.user_position."entityType" in ('logout','login')) )
        group by  geo.user_position."dateCreated", geo.user_position."userId", geo.user_position."Id", "itemType", geo.user_position.latitude, geo.user_position.longitude,geo.user_position.accuracy,
        geo.address."address",  geo.user_position."clientIp"
    ),
    union_actions as (
    Select "activity_status_changes".* from "activity_status_changes"
    union all select "comment_changes".* from "comment_changes"
    union all select "agent_actions".* from "agent_actions"
    union all select "agent_log".* from "agent_log"
    )
    select DISTINCT count(*) over () as "rowCount", concat (master.user."firstName", ' ', master.user."lastName") as "name", master.user."userName" as "userName", union_actions.*,
    ARRAY_AGG(DISTINCT COALESCE(sales.team."name", '(no team)')) AS "salesTeam",
    ARRAY_AGG(DISTINCT COALESCE(leader."lastName", '(no leader)')) AS "teamLeader"
    from union_actions
    inner join master.user on master.user."Id" = union_actions."userId"
    left join sales.team_member ON sales.team_member."userId" = union_actions."userId"
    left join sales.team ON sales.team."Id" = sales.team_member."teamId"
    left join master.user leader on leader."Id" = sales.team."leaderId"
    
    WHERE (union_actions."dateCreated"::date BETWEEN ('2024-11-01 00:00:00.000'::date) and ('2024-11-15 23:59:00.000'::date))
            AND
            (
                isinsystemrole('94b16681-f011-44ff-9697-92decee082a3', 'loan officer') = true AND (union_actions."userId"  = '94b16681-f011-44ff-9697-92decee082a3') -- OWN user action ONLY
            )
            or
            --if user is in team leader role, only return their own team
            (
                isinsystemrole('94b16681-f011-44ff-9697-92decee082a3', 'team leader') = true
                AND ((union_actions."userId" in (select "userId" from "sales"."team_member"
                WHERE "sales"."team_member"."teamId" IN (Select "Id" from "sales"."team" WHERE "sales"."team"."leaderId" = '94b16681-f011-44ff-9697-92decee082a3')))
                OR (union_actions."userId" = '94b16681-f011-44ff-9697-92decee082a3')) -- include own user
            )
            OR
            --if user is not in team leader role, return all teams for tenant
            (
            (isinsystemrole('94b16681-f011-44ff-9697-92decee082a3', 'team leader') = false AND isinsystemrole('94b16681-f011-44ff-9697-92decee082a3', 'loan officer') = false AND union_actions."userId" in (select "userId" from "master"."tenant_user"
            WHERE "master"."tenant_user"."tenantId"
            in (select "Id" from gettenantdescendents('e27300b5-c575-4f85-b087-9079b8c85f07')))
            AND (('' != '' AND isinsystemrole(union_actions."userId", '') = true) OR ('' = '')))
            OR (('' != '' AND isinsystemrole(union_actions."userId", 'team leader'))) -- include team leaders
            )
        AND (
            union_actions."userId" NOT IN (SELECT "itemId" FROM master.status WHERE "itemType" = 'User' AND "status" = 'DELETED')
        )
        AND (
            UPPER(concat (master.user."firstName", ' ', master.user."lastName")) LIKE UPPER('%%%%') OR
            UPPER("description") LIKE UPPER('%%%%')
        )

        group by master.user."firstName", master.user."lastName", master.user."userName", union_actions."Id", union_actions."userId" , "itemId", "itemType",
        "description", "action", union_actions."dateCreated",  latitude, longitude, accuracy, address, union_actions."clientIp"
        ORDER BY union_actions."dateCreated" DESC OFFSET 0 LIMIT 100