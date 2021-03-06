SELECT 
    group_concat(obs.value_numeric separator ', ') as ICU1stHeartRate, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '9360b4f4-4456-4bc2-97fd-68e661a19d78'
WHERE 
      obs.voided = 0