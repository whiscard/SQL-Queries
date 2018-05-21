SELECT 
	count(stock_operation_id),
    date_format(date_created, '%Y-%M') AS Year
FROM inv_stock_operation
WHERE
	retired = 0
    AND status = 'COMPLETED'
GROUP BY date_format(date_created, '%Y-%M')
ORDER BY date_format(date_created, '%Y-%m')