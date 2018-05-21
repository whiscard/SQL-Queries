SELECT 
	group_concat(concat_ws(', ', cname.name, obs.value_text) SEPARATOR ', ')  as DischargeDiagnosis,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
WHERE 
	  obs.concept_id IN (1284,1642,161602)
      AND obs.voided = 0
      GROUP BY v.visit_id