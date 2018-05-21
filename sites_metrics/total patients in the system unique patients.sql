SELECT 
	count(patient_id),
    date_format(date_created, '%Y') AS Year
FROM patient
WHERE voided = 0 
GROUP BY date_format(date_created, '%Y')