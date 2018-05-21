SELECT 
	group_concat(obs.value_numeric separator ', ') as A1c, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '159644AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE 
      obs.voided = 0