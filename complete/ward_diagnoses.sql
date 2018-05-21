SELECT 
    WardDiagnosis.diagnosis as diagnosis,
    WardDiagnosis.visit_id as visit_id,
    WardDiagnosis.calendar as calendar,
    WardDiagnosis.calendar_obs_date as calendar_obs_date,
    WardDiagnosis.person_id as person_id,
    WardDiagnosis.NoOfDiagnosis as NoOfDiagnosis

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
      (CAST(v.date_stopped AS DATE) BETWEEN CAST( '2016-10-01' AS DATE) AND CAST( '2017-11-30' AS DATE))
) AS WardDiagnosis
LEFT OUTER JOIN
(
SELECT 
    obs.value_coded, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept WardStayQn ON obs.concept_id = WardStayQn.concept_id
    AND WardStayQn.uuid = '59073230-e0d9-4cbc-bebc-4bf91a42f3bb'
WHERE  
	  obs.voided = 0
      AND obs.value_coded = 1065
) AS WardStayYES ON WardDiagnosis.visit_id = WardStayYES.visit_id
LEFT OUTER JOIN
(      
SELECT 
	obs.value_coded, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept HDUStayQn ON obs.concept_id = HDUStayQn.concept_id
    AND HDUStayQn.uuid = '46d4283e-3275-4c6e-9d52-cfd858889f4b'
WHERE  
	  obs.voided = 0
      AND obs.value_coded = 1065
) AS HDUStayYES ON WardDiagnosis.visit_id = HDUStayYES.visit_id
WHERE
	WardStayYES.value_coded = 1065 OR HDUStayYES.value_coded = 1065