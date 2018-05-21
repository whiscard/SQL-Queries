SELECT 
	cname.name as ICU1stSBP, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICU1stSBPQn ON obs.concept_id = ICU1stSBPQn.concept_id
    AND ICU1stSBPQn.uuid = '8f7ad9c2-aca6-458e-9362-963b4d391a7c'
WHERE  
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"