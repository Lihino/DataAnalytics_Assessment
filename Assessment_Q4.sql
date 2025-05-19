-- Using the plan's table instead of the savings table because we jhave the followings in the plan's table, the start_date column, amount and owner_id tcoloumn will be selected from the plan's table

select u.id as Customer_id,
u.Full_name,
timestampdiff(Month, p.start_date, now()) as Tenure_months,
count(p.amount) as Total_transactions,
round(
(count(p.amount) / Nullif(timestampdiff(Month, p.start_date, now()), 0))*12
*(avg(p.amount)* 0.001), 2
) as Estimate_CLV
from users_customuser u
join plans_plan p on u.id = p.owner_id
where p.amount is not null
and u.Full_name is not null
and p.start_date is not null
group by u.id, start_date
order by estimate_CLV desc;