SELECT 
	count(bill_id),
    date_format(date_created, '%Y-%M') AS Year
FROM cashier_bill
WHERE 
	voided = 0
GROUP BY date_format(date_created, '%Y-%M')
ORDER BY date_format(date_created, '%Y-%m')