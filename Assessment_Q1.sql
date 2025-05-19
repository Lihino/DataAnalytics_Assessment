

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