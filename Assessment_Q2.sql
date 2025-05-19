
-- Creating a CTE (Common table expression) to simplify the query and summarize the transaction data groupig it by the owner id the avg transaction monthly per user by diving the count of users by their distinct transaction date. 
-- referencing the CTE and combining the case function we can now query the Frequency category column, by the customer count and sorting by the avg transaction per month

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