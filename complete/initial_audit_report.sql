SELECT
	ObsCompleteAuditData.CompleteAuditData,
	PatientDemographics.PatientName,
    PatientDemographics.HospID,
    PatientDemographics.DOA,
    PatientDemographics.DOD,
    ObsDeathHospital.DeathHospital,
    PatientDemographics.Age,
    ObsInpatientService.InpatientService,
    PatientDemographics.Location,
    ObsPreOP.PreOP,
    PatientDemographics.Gender,
    ObsPalliativeConsult.PalliativeConsult,
    ObsICUStay.ICUStay,
    ObsHDUStay.HDUStay,
    ObsHDUCoMngt.HDUCoMngt,
    ObsDischargeDiagnosis.DischargeDiagnosis,
    ObsA1c.A1c,
    ObsHIV.HIV,
    ObsCD4.CD4,
    datediff(PatientDemographics.DOD,PatientDemographics.DOA) AS 'LOS (DAYS)' 
    
FROM

(
SELECT
	concat(ifnull(person_name.given_name,''), ' ', ifnull(person_name.middle_name,''), ' ', ifnull(person_name.family_name,'')) AS PatientName,
	patient_identifier.identifier AS HospID,
	cast(visit.date_started as DATE) AS DOA,
	cast(visit.date_stopped as DATE) AS DOD,
	timestampdiff(year, person.birthdate,visit.date_started) AS Age,
	person.gender AS Gender,
	cname.name AS Location,
    visit.visit_id

FROM 
	visit 
	INNER JOIN patient ON visit.patient_id = patient.patient_id
	INNER JOIN person ON patient.patient_id = person.person_id
	INNER JOIN person_name ON person.person_id = person_name.person_id
	INNER JOIN visit_attribute va ON visit.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid
    INNER JOIN concept_name cname ON ca.answer_concept = cname.concept_id
    AND cname.locale = 'en'
	LEFT OUTER JOIN patient_identifier ON patient.patient_id = patient_identifier.patient_id
    AND
    patient_identifier.identifier_type = 5

WHERE ((CAST(visit.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ca.answer_concept = $P{ward}
	 	 
ORDER BY visit.date_started ASC
) AS PatientDemographics
LEFT OUTER JOIN
(
SELECT 
	cname.name as CompleteAuditData, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164174
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsCompleteAuditData ON PatientDemographics.visit_id = ObsCompleteAuditData.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as DeathHospital, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164173
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsDeathHospital ON PatientDemographics.visit_id = ObsDeathHospital.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as PalliativeConsult, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164166
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsPalliativeConsult ON PatientDemographics.visit_id = ObsPalliativeConsult.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as PreOP, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164164
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsPreOP ON PatientDemographics.visit_id = ObsPreOP.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUStay, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164168
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsICUStay ON PatientDemographics.visit_id = ObsICUStay.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as HDUStay, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164167
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsHDUStay ON PatientDemographics.visit_id = ObsHDUStay.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as HDUCoMngt, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164165
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsHDUCoMngt ON PatientDemographics.visit_id = ObsHDUCoMngt.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as HIV, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 1169
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsHIV ON PatientDemographics.visit_id = ObsHIV.visit_id
LEFT OUTER JOIN
(
SELECT 
	obs.value_numeric as CD4, 
    v.visit_id

FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE 
	  enc.encounter_type = 13 
      AND obs.voided = 0
	  AND obs.concept_id = 5497
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsCD4 ON PatientDemographics.visit_id = ObsCD4.visit_id
LEFT OUTER JOIN
(
SELECT 
	obs.value_numeric as A1c, 
    v.visit_id

FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE 
	  enc.encounter_type = 13 
      AND obs.voided = 0
	  AND obs.concept_id = 159644
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsA1c ON PatientDemographics.visit_id = ObsA1c.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as InpatientService, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 161630
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

ORDER BY v.date_started asc
) AS ObsInpatientService ON PatientDemographics.visit_id = ObsInpatientService.visit_id
LEFT OUTER JOIN
(
SELECT 
	group_concat(cname.name, "")  as DischargeDiagnosis, 
    v.visit_id

FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN visit_attribute va ON v.visit_id = va.visit_id
    AND va.voided = 0
    INNER JOIN concept_answer ca ON va.value_reference = ca.uuid

WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 1642
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
      AND ((CAST(v.date_started as DATE) BETWEEN CAST($P{beginDate} AS DATE)  AND CAST($P{endDate} AS DATE)))
      AND ca.answer_concept = $P{ward}

GROUP BY v.visit_id
ORDER BY v.date_started asc
) AS ObsDischargeDiagnosis ON PatientDemographics.visit_id = ObsDischargeDiagnosis.visit_id

ORDER BY PatientDemographics.DOA asc
