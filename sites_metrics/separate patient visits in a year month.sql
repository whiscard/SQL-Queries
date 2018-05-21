SELECT 
	count(patient_id),
    date_format(date_started, '%Y-%M') AS Year
FROM visit
WHERE voided = 0 
GROUP BY date_format(date_started, '%Y-%M')
ORDER BY date_format(date_started, '%Y-%m')