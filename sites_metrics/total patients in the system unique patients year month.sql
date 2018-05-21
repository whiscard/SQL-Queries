SELECT 
	count(patient_id),
    date_format(date_created, '%Y-%M') AS Year
FROM patient
WHERE voided = 0 
GROUP BY date_format(date_created, '%Y-%M')
ORDER BY date_format(date_created, '%Y-%m')