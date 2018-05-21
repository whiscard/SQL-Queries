SELECT 
	count(stock_operation_id),
    date_format(date_created, '%Y') AS Year
FROM inv_stock_operation
WHERE
	retired = 0
    AND status = 'COMPLETED'
GROUP BY date_format(date_created, '%Y')