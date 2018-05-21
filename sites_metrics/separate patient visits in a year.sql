SELECT 
	count(patient_id),
    date_format(date_started, '%Y') AS Year
FROM visit
WHERE voided = 0 
GROUP BY date_format(date_started, '%Y')