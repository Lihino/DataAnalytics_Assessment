
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