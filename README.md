# DataAnalytics_Assessment
## Cowrywise Assessment 


### 1. High-Value Customers with Multiple Products
Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

### Solution
(-- First we check all our extracted data and see where we have to start from.. The users_customuser
-- has the customer demographics and contact information
-- So, I am writing a query to extract and transform the first and last name of each customers
Select concat(first_name,' ', last_name) as Full_name
from users_customuser;

-- After the extraction, I am altering the users_customuser table to have a column named Full_name to occupy the first and last name data
Alter table users_customuser
Add Full_name varchar(1000);

-- Then, I update the table and Full_name coloumn to have the queried data
update users_customuser
set Full_name = concat(first_name,' ', last_name);

-- My quick check to know if what I have done works
select Full_name, id
from users_customuser;

-- A quick check on the plans_plan table
select *
from plans_plan;

-- On the plans_plan table I am distintifly counting the is_fixed_investment column and the is_regular_savings column and rename it as 
-- Investment_count and Savings_count respectively grouping it by ownership_id.
select count(distinct is_fixed_investment) as Investment_count, count(distinct is_regular_savings) as Savings_count, owner_id
from plans_plan
group by owner_id;

-- A quick check on the savings_savingsaccount table
select *
from savings_savingsaccount;

-- Using the new_balance column to represent the total deposit in the account of customers, rounded to two decimal points grouping it by the owners_id and sorting it by total deposit the result shows the total deposit by the owners_id
select round(max(new_balance), 2) as total_deposit, owner_id
from savings_savingsaccount
group by owner_id
order by total_deposit desc;


Select count(distinct new_balance) as Savings, owner_id
from savings_savingsaccount
group by owner_id
order by Savings desc
limit 1;

-- Bringing all the queries together to create a larger query
-- Converting the id column in users_customuser table as the owner_id since there is a relationship between the id column in users_customuser table and the plans table
-- Select the users table owner_id, users table full_name, plans table Ivestment_count, plans table Savings_count, and the savings table total_deposit column to be represented
-- representing the users table as u, the plans table as p, and the savings table as s. Join the plans table on the users table using the primary key id column on the plans owner_id
-- Also left join the savings table on the plans table using the primary key owner_id. Group it all by Owner_id and Full_name Sort ny total_deposit
SELECT 
  u.id AS owner_id,
  u.Full_name,
  COUNT(DISTINCT p.is_fixed_investment) AS Investment_count,
  COUNT(DISTINCT p.is_regular_savings) AS Savings_count,
  Round(MAX(s.new_balance),2) AS total_deposit
FROM users_customuser u
Inner JOIN plans_plan p ON u.id = p.owner_id
inner JOIN savings_savingsaccount s ON p.owner_id = s.owner_id
GROUP BY u.id, u.Full_name
order by total_deposit desc
;


-- After joining the tables and getting the required result, it is now time to clean out the null values to have a well cleaned and analysed result.
SELECT 
  u.id AS owner_id,
  u.Full_name,
  COUNT(DISTINCT p.is_fixed_investment) AS Investment_count,
  COUNT(DISTINCT p.is_regular_savings) AS Savings_count,
  round(max(s.new_balance), 2) AS total_deposit
FROM users_customuser u
INNER JOIN plans_plan p ON u.id = p.owner_id
INNER JOIN savings_savingsaccount s ON p.owner_id = s.owner_id
WHERE 
  p.is_fixed_investment IS NOT NULL AND 
  p.is_regular_savings IS NOT NULL AND
  s.confirmed_amount IS NOT NULL AND
  u.Full_name IS NOT NULL
GROUP BY u.id, u.Full_name
order by total_deposit desc
limit 20;

### 2. Transaction Frequency Analysis
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
Task: Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month)

### Solution

-- Using the CASE function to detemine when the Frequency category is either in High frequency, medium or in low frequency

Select count(owner_id) as Customer_count,
Case 
	When count(owner_id) / count(distinct date_format(transaction_date, '%Y-%m')) >= 10 then 'High Frequency'
    When count(owner_id) / count(distinct date_format(transaction_date, '%Y-%m')) between 3 and 9 then 'Medium Frequency'
    else 'Low Frequency'
end as Frequency_category
from savings_savingsaccount
where transaction_date is not null
group by owner_id
order by Customer_count desc;

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

### Comment 
-- The result shows High Frequency with customer count of 141, and Avg transaction monthly of 44.72
-- The resut show medium frequency with 178 customer count and 4.57 average transaction monthly
-- The low frequency has the largest customer count with 554 and an avg transaction monthly

### 3. Account Inactivity Alert
Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

### Solution

-- A quick look into the plans table to figure out the coloumns needed which include the plan_id, owner_id, investment column, savings and the last_charge date.
select *
from plans_plan;

-- Qucik look into the savings table suggest the table is not needed for the querying
select *
from savings_savingsaccount;

Select 
id as plan_id, 
owner_id, 
'savings' as type,
last_charge_date, 
datediff(now(), last_charge_date) as inactive_days
from plans_plan
where status_id = 1 
and is_regular_savings = 1
and (last_charge_date is not null or last_charge_date < date_sub(now(), Interval 365 day))
order by inactive_days desc;

-- Select the id column as the plan_id, the owner_id, Using case function define the investment and savings column, select the last charge date and define the inactivity day by diff the day from todays date
-- from the plans table where the status of of the account is 1(active) and the last charge date is not null and the investment and savings account is also active. Sorting it by the inactivity days in descending order 

SELECT 
  id AS plan_id,
  owner_id,
  CASE 
    WHEN is_fixed_investment = 1 THEN 'Investment'
    WHEN is_regular_savings = 1 THEN 'Savings'
    ELSE 'Unknown'
  END AS type,
  last_charge_date,
  DATEDIFF(NOW(), last_charge_date) AS inactivity_days
FROM plans_plan
WHERE status_id = 1
  AND (last_charge_date IS not NULL OR last_charge_date < DATE_SUB(NOW(), INTERVAL 365 DAY))
  AND (is_fixed_investment = 1 OR is_regular_savings = 1)
ORDER BY inactivity_days DESC;

### Comment
-- The reult shows that Cowrywise has active savings accounts with over 500 days of inactivity.
-- The result also shows there are lots of savings account with inactive days in cowrywise
-- The result show no Investment accounts with inactive days nor are there any investment accounts that are active.

### 4. Customer Lifetime Value (CLV) Estimation
Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest


### Solution

-- A quick look into the users table, we need to select the id and the full name column
Select *
from users_customuser;

-- Renmae the id column as the Customer_id and select the Full_name from the users table
Select id as customer_id, 
Full_name
from users_customuser;

-- Using the plan's table instead of the savings table, the start_date column, amount and owner_id tcoloumn will be selected from the plan's table
select *
from plans_plan;

-- Calculating the count of the amounts by customers, converting the start_date into months as tenure_month using the timestampdiff
Select owner_id, 
count(amount) as total_transactions,
round(avg(amount)* 0.001, 2) as avg_profit_per_transaction,
timestampdiff(Month, start_date, now()) as Tenure_months
from plans_plan
group by owner_id, start_date;

-- Calculating the Estimate_Customer_lifetime_value by divinging the total amount by the tenure and multplying it by 12 and avg_profit_per_transaction
Select owner_id, 
count(amount) as total_transactions, 
round(
(count(amount) / Nullif(timestampdiff(Month, start_date, now()), 0))*12
*(avg(amount)* 0.001), 2
) as Estimate_CLV,
timestampdiff(Month, start_date, now()) as Tenure_months
from plans_plan
group by owner_id, start_date;

-- Joining the users tabe and plans table together using the foreign keys and primary keys, removing all the null values and sorting by estimate_customer lifetime value.

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

### Comment
-- Result shows that Christiana Uzonowanne has the highest estimate Clv
-- The report shows the Tenure and Total transaction coulumns.




