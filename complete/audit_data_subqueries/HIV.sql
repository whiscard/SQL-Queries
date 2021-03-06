SELECT 
	cname.name as HIV, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept HIVQn ON obs.concept_id = HIVQn.concept_id
    AND HIVQn.uuid = '1169AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE  
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"