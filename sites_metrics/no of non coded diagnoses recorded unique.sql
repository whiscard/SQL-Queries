SELECT
	date_format(obs.obs_datetime, '%Y') AS Year,
    count(distinct(obs.value_text)) as NoOfDiagnosis
FROM obs obs
	
WHERE 
	  obs.concept_id IN (1284,1642,161602)
      AND obs.voided = 0
GROUP BY 	date_format(obs.obs_datetime, '%Y')