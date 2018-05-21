SELECT
    ICUDiagnosis.diagnosis as diagnosis,
    ICUDiagnosis.visit_id as visit_id,
    ICUDiagnosis.calendar as calendar,
    ICUDiagnosis.calendar_obs_date as calendar_obs_date,
    ICUDiagnosis.person_id as person_id,
    ICUDiagnosis.NoOfDiagnosis as NoOfDiagnosis
FROM
(
SELECT
	coalesce(cname.name,obs.value_text) as diagnosis,
    v.visit_id,
    date(v.date_stopped) as calendar,
    date(obs.obs_datetime) as calendar_obs_date,
    obs.person_id,
    coalesce(obs.value_coded,obs.value_text) as NoOfDiagnosis
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
      AND
      (CAST(v.date_stopped AS DATE) BETWEEN CAST( '2017-10-01' AS DATE) AND CAST( '2017-10-31' AS DATE))
) AS ICUDiagnosis
INNER JOIN
(
SELECT 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept ICUstayQN  ON ICUstayQN.concept_id = obs.concept_id
    AND ICUstayQN.uuid = '9446f7aa-7a1c-4246-a0a5-1ebc3560a0e0'
WHERE 
	  obs.value_coded = 1065
      AND obs.voided = 0
      AND (CAST(v.date_stopped AS DATE) BETWEEN CAST( '2017-10-01' AS DATE) AND CAST( '2017-10-31' AS DATE))
) AS ICUVisits ON ICUDiagnosis.visit_id = ICUVisits.visit_id