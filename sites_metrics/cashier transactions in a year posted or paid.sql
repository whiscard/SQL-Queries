SELECT 
	count(bill_id),
    date_format(date_created, '%Y') AS Year
FROM cashier_bill
WHERE 
	voided = 0
	AND
    status IN ('PAID','POSTED')
GROUP BY date_format(date_created, '%Y')