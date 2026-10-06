use liocinema_db;
use jotstar_db;


select * from content_consumption;
select * from contents;
select * from subscribers;


-- Questions from the available data (Primary)

-- 1. Total Users & Growth Trends
-- ● What is the total number of users for LioCinema and Jotstar, and how do they
-- compare in terms of growth trends (January–November 2024)?

SELECT
    'LioCinema_db' AS platform,
    MONTHNAME(subscription_date) AS month,
    COUNT(*) AS total_users
FROM liocinema_db.subscribers
WHERE YEAR(subscription_date) = 2024
GROUP BY MONTH(subscription_date), MONTHNAME(subscription_date)

UNION ALL

SELECT
    'Jotstar_db' AS platform,
    MONTHNAME(subscription_date) AS month,
    COUNT(*) AS total_users
FROM jotstar_db.subscribers
WHERE YEAR(subscription_date) = 2024
GROUP BY MONTH(subscription_date), MONTHNAME(subscription_date)

ORDER BY month;

-- 2. Content Library Comparison
-- ● What is the total number of contents available on LioCinema vs. Jotstar? How do
-- they differ in terms of language and content type?

select 
'jotstar_db' as platform,
content_type,
language,
count(*) as number_contents
from contents
group by language, content_type

union all

select 
'liocinema_db' as platform,
content_type,
language,
count(*) as number_contents
from contents
group by language, content_type

-- total contents

SELECT
    'Jotstar' AS platform,
    COUNT(*) AS total_contents
FROM jotstar_db.contents

UNION ALL

SELECT
    'LioCinema' AS platform,
    COUNT(*) AS total_contents
FROM liocinema_db.contents;

-- 3. User Demographics
-- ● What is the distribution of users by age group, city tier, and subscription plan for each
-- platform?

select
'jotstar.db' as platform,
age_group,
city_tier,
subscription_plan,
count(*) as total_users
from subscribers
GROUP BY age_group, city_tier, subscription_plan

union all

select
'liocinema.db' as platform,
age_group,
city_tier,
subscription_plan,
count(*) as total_users
from subscribers
GROUP BY age_group, city_tier, subscription_plan
ORDER BY platform, age_group, city_tier;

-- 4. Active vs. Inactive Users
-- ● What percentage of LioCinema and Jotstar users are active vs. inactive? How do
-- these rates vary by age group and subscription plan?

select
'liocinema_db' as platform,
age_group,
subscription_plan,
case
when last_active_date is null then 'Inactive'
else 'Active'
end as user_status,
count(*) as total_users,
Round((count(*)*100 / (select count(*) from liocinema_db.subscribers)), 2) as percentage
from liocinema_db.subscribers
GROUP BY age_group, subscription_plan, user_status

union all


select
'jotstar_db' as platform,
age_group,
subscription_plan,
case
when last_active_date is null then 'Inactive'
else 'Active'
end as user_status,
count(*) as total_users,
Round((count(*)*100 / (select count(*) from jotstar_db.subscribers)), 2) as percentage
from jotstar_db.subscribers
group by age_group, subscription_plan, user_status
order by platform, age_group, subscription_plan;

-- 5. Watch Time Analysis
-- ● What is the average watch time for LioCinema vs. Jotstar during the analysis period?
-- How do these compare by city tier and device type?

select
'jotstar_db' as platform,
Round(avg(c.total_watch_time_mins), 2) as average_watch_time,
c.device_type,
s.city_tier
from jotstar_db.content_consumption c
join jotstar_db.subscribers s
on c.user_id = s.user_id
group by s.city_tier, c.device_type

union all

select
'liocinema_db' as platform,
Round(avg(c.total_watch_time_mins), 2) as average_watch_time,
c.device_type,
s.city_tier
from liocinema_db.content_consumption c
join liocinema_db.subscribers s
on c.user_id = s.user_id
group by s.city_tier, c.device_type
order by platform, average_watch_time desc;

-- 6. Inactivity Correlation
-- ● How do inactivity patterns correlate with total watch time or average watch time? Are
-- less engaged users more likely to become inactive?

select 
'liocinema_db' as platform,
case
when s.last_active_date is null then 'Inactive'
else 'Active'
End as User_status,
Round(avg(c.total_watch_time_mins), 2) as average_watch_time
from liocinema_db.content_consumption c
join liocinema_db.subscribers s
on s.user_id = c.user_id
group by user_status

union all
select
'jotstar_db' as platform,
case
when s.last_active_date is null then 'Inactive'
else 'Active'
End as User_status,
Round(avg(c.total_watch_time_mins),2) as average_watch_time
from jotstar_db.content_consumption c
join jotstar_db.subscribers s
on s.user_id = c.user_id
group by user_status
order by Platform, user_status;

-- 7. Downgrade Trends
-- ● How do downgrade trends differ between LioCinema and Jotstar? Are downgrades
-- more prevalent on one platform compared to the other?

-- 7. Downgrade Trends

SELECT
    'LioCinema' AS platform,
    subscription_plan AS old_plan,
    new_subscription_plan AS new_plan,
    COUNT(*) AS downgrade_count
FROM liocinema_db.subscribers
WHERE
    (subscription_plan = 'Premium' AND new_subscription_plan IN ('Basic','Free'))
    OR
    (subscription_plan = 'Basic' AND new_subscription_plan = 'Free')
GROUP BY subscription_plan, new_subscription_plan

UNION ALL

SELECT
    'Jotstar' AS platform,
    subscription_plan AS old_plan,
    new_subscription_plan AS new_plan,
    COUNT(*) AS downgrade_count
FROM jotstar_db.subscribers
WHERE
    (subscription_plan = 'Premium' AND new_subscription_plan IN ('VIP','Free'))
    OR
    (subscription_plan = 'VIP' AND new_subscription_plan = 'Free')
GROUP BY subscription_plan, new_subscription_plan

ORDER BY downgrade_count DESC;

-- 8. Upgrade Patterns
-- ● What are the most common upgrade transitions (e.g., Free to Basic, Free to VIP,
-- Free to Premium) for LioCinema and Jotstar? How do these differ across platforms?

-- 8. Upgrade Patterns

SELECT
    'LioCinema' AS platform,
    subscription_plan AS old_plan,
    new_subscription_plan AS new_plan,
    COUNT(*) AS upgrade_count
FROM liocinema_db.subscribers
WHERE
    (subscription_plan = 'Free' AND new_subscription_plan IN ('Basic','Premium'))
    OR
    (subscription_plan = 'Basic' AND new_subscription_plan = 'Premium')
GROUP BY subscription_plan, new_subscription_plan

UNION ALL

SELECT
    'Jotstar' AS platform,
    subscription_plan AS old_plan,
    new_subscription_plan AS new_plan,
    COUNT(*) AS upgrade_count
FROM jotstar_db.subscribers
WHERE
    (subscription_plan = 'Free' AND new_subscription_plan IN ('VIP','Premium'))
    OR
    (subscription_plan = 'VIP' AND new_subscription_plan = 'Premium')
GROUP BY subscription_plan, new_subscription_plan

ORDER BY upgrade_count DESC;

-- 9. Paid Users Distribution
-- ● How does the paid user percentage (e.g., Basic, Premium for LioCinema; VIP,
-- Premium for Jotstar) vary across different platforms? Analyse the proportion of
-- premium users in Tier 1, Tier 2, and Tier 3 cities and identify any notable trends or
-- differences

-- 9. Paid Users Distribution

SELECT
    'Jotstar' AS platform,
    city_tier,
    subscription_plan,
    COUNT(*) AS paid_users,
    ROUND(COUNT(*) * 100 /
        (SELECT COUNT(*) FROM jotstar_db.subscribers
         WHERE subscription_plan IN ('VIP','Premium')),2) AS percentage
FROM jotstar_db.subscribers
WHERE subscription_plan IN ('VIP','Premium')
GROUP BY city_tier, subscription_plan

UNION ALL

SELECT
    'LioCinema' AS platform,
    city_tier,
    subscription_plan,
    COUNT(*) AS paid_users,
    ROUND(COUNT(*) * 100 /
        (SELECT COUNT(*) FROM liocinema_db.subscribers
         WHERE subscription_plan IN ('Basic','Premium')),2) AS percentage
FROM liocinema_db.subscribers
WHERE subscription_plan IN ('Basic','Premium')
GROUP BY city_tier, subscription_plan

ORDER BY platform, city_tier, subscription_plan;

-- 10. Revenue Analysis
-- ● Assume the following monthly subscription prices, calculate the total revenue
-- generated by both platforms (LioCinema and Jotstar) for the analysis period (January
-- to November 2024). 

SELECT
    'LioCinema' AS platform,
    ROUND(SUM(
        (
            TIMESTAMPDIFF(MONTH, subscription_date, COALESCE(plan_change_date,'2024-11-30'))
            *
            CASE
                WHEN subscription_plan='Basic' THEN 69
                WHEN subscription_plan='Premium' THEN 129
                ELSE 0
            END
        )
        +
        (
            IFNULL(TIMESTAMPDIFF(MONTH, plan_change_date,'2024-11-30'),0)
            *
            CASE
                WHEN new_subscription_plan='Basic' THEN 69
                WHEN new_subscription_plan='Premium' THEN 129
                ELSE 0
            END
        )
    ),2) AS total_revenue
FROM liocinema_db.subscribers

UNION ALL

SELECT
    'Jotstar' AS platform,
    ROUND(SUM(
        (
            TIMESTAMPDIFF(MONTH, subscription_date, COALESCE(plan_change_date,'2024-11-30'))
            *
            CASE
                WHEN subscription_plan='VIP' THEN 159
                WHEN subscription_plan='Premium' THEN 359
                ELSE 0
            END
        )
        +
        (
            IFNULL(TIMESTAMPDIFF(MONTH, plan_change_date,'2024-11-30'),0)
            *
            CASE
                WHEN new_subscription_plan='VIP' THEN 159
                WHEN new_subscription_plan='Premium' THEN 359
                ELSE 0
            END
        )
    ),2) AS total_revenue
FROM jotstar_db.subscribers;

