

with transaction_summary as (select count(owner_id) as Customer_count,
count(owner_id) / count(distinct date_format(transaction_date, '%Y-%m')) as avg_transaction_per_month_user
from savings_savingsaccount
where transaction_date is not null
group by owner_id
)
Select 
Case 
	When avg_transaction_per_month_user >= 10 then 'High Frequency'
    When avg_transaction_per_month_user between 3 and 9 then 'Medium Frequency'
    else 'Low Frequency'
end as Frequency_category,
count(*) as Customer_count, 
round(avg(avg_transaction_per_month_user), 2) as Avg_transaction_per_month
from transaction_summary
group by Frequency_category
order by Avg_transaction_per_month desc;