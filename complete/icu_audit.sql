SELECT
    PatientDemographics.visit_id,
    ObsCompleteAuditData.CompleteAuditData,
    PatientDemographics.PatientName,
    PatientDemographics.HospID,
    PatientDemographics.DOA,
    PatientDemographics.DOD,
    ObsDeathHospital.DeathHospital,
    PatientDemographics.Age,
    PatientDemographics.Gender,
    IMedWard.Location,
    ObsInpatientService.InpatientService,
    ObsPreOP.PreOP,
    ObsPalliativeConsult.PalliativeConsult,
    ObsHIV.HIV,
    ObsCD4.CD4,
    ObsPatientDiabetic.PatientDiabetic,
    ObsA1c.A1c,
    ObsWardStay.WardStay,
    ObsHDUStay.HDUStay,
    ObsHDUCoMngt.HDUCoMngt,
    ObsDischargeDiagnosis.DischargeDiagnosis,
    datediff(PatientDemographics.DOD,PatientDemographics.DOA) AS 'LOS (DAYS)',
    ObsICUStay.ICUStay,
    ObsICUMechanicalventilation.ICUMechanicalventilation,
    ObsICUReceivedvaospressors.ICUReceivedvaospressors,
    ObsICUInfection.ICUInfection,
    ObsICU1stSBP.ICU1stSBP,
    ObsICU1stMAP.ICU1stMAP,
    ObsICUSedation.ICUSedation,
    ObsICUSurgery.ICUSurgery,
    ObsICU1stHeartRate.ICU1stHeartRate,
    ObsICU1stGCSscore.ICU1stGCSscore
FROM
(
SELECT
	concat(ifnull(person_name.given_name,''), ' ', ifnull(person_name.middle_name,''), ' ', ifnull(person_name.family_name,'')) AS PatientName,
	patient_identifier.identifier AS HospID,
	cast(visit.date_started as DATE) AS DOA,
	cast(visit.date_stopped as DATE) AS DOD,
	timestampdiff(year, person.birthdate,visit.date_started) AS Age,
	person.gender AS Gender,
	visit.visit_id
FROM 
	visit 
	INNER JOIN patient ON visit.patient_id = patient.patient_id
	INNER JOIN person ON patient.patient_id = person.person_id
	INNER JOIN person_name ON person.person_id = person_name.person_id
	LEFT OUTER JOIN patient_identifier ON patient.patient_id = patient_identifier.patient_id
    AND
    patient_identifier.identifier_type = 5
GROUP BY visit.visit_id	 	 
) AS PatientDemographics
LEFT OUTER JOIN
(
SELECT
	group_concat(cname.name separator ', ') AS Location,
    va.visit_id
FROM 
	visit_attribute va
	INNER JOIN concept_answer ca_ward ON va.value_reference = ca_ward.uuid
    INNER JOIN concept_name cname ON ca_ward.answer_concept = cname.concept_id
    AND cname.locale = 'en'
WHERE cname.concept_name_type = "FULLY_SPECIFIED"
      AND va.value_reference IN ('0f604753-3b1e-4396-8c65-129fbcb9fd9f','90ebd638-c928-426b-9427-b25e1fa70f91',
	'4eff276b-8369-4933-bdad-105986977264','44ff45ba-38ec-44e7-b6cd-9350b2b3a16d',
	'403c4533-c598-4483-bf8c-ad8eb405ebdf','7e63ac76-3479-41b6-ad68-ac3259cbdbd4',
	'26b283b1-0639-4d15-9716-6364257d9966','aa1146dd-230d-42c8-8530-daecf62cfbc5')
GROUP BY va.visit_id
) AS IMedWard ON PatientDemographics.visit_id = IMedWard.visit_id
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164174
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164173
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164166
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164164
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPreOP ON PatientDemographics.visit_id = ObsPreOP.visit_id
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164167
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164165
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
GROUP BY v.visit_id
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 1169
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
GROUP BY v.visit_id
) AS ObsHIV ON PatientDemographics.visit_id = ObsHIV.visit_id
LEFT OUTER JOIN
(
SELECT 
	group_concat(obs.value_numeric separator ', ') AS CD4, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
WHERE 
	  enc.encounter_type = 13 
      AND obs.voided = 0
	  AND obs.concept_id = 5497
GROUP BY v.visit_id
) AS ObsCD4 ON PatientDemographics.visit_id = ObsCD4.visit_id
#
LEFT OUTER JOIN
(
SELECT 
    cname.name as PatientDiabetic, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
    INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164199
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPatientDiabetic ON PatientDemographics.visit_id = ObsPatientDiabetic.visit_id
#
LEFT OUTER JOIN
(
SELECT 
	group_concat(obs.value_numeric separator ', ') as A1c, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
WHERE 
	  enc.encounter_type = 13 
      AND obs.voided = 0
	  AND obs.concept_id = 159644
GROUP BY v.visit_id
) AS ObsA1c ON PatientDemographics.visit_id = ObsA1c.visit_id
#
LEFT OUTER JOIN
(
SELECT 
    cname.name as WardStay, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
    INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164200
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsWardStay ON PatientDemographics.visit_id = ObsWardStay.visit_id
#
##
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
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164168
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUStay ON PatientDemographics.visit_id = ObsICUStay.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUMechanicalventilation, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164188
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUMechanicalventilation ON PatientDemographics.visit_id = ObsICUMechanicalventilation.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUReceivedvaospressors, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164189
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUReceivedvaospressors ON PatientDemographics.visit_id = ObsICUReceivedvaospressors.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUInfection, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164193
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUInfection ON PatientDemographics.visit_id = ObsICUInfection.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICU1stSBP, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164194
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICU1stSBP ON PatientDemographics.visit_id = ObsICU1stSBP.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICU1stMAP, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164195
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICU1stMAP ON PatientDemographics.visit_id = ObsICU1stMAP.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUSedation, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164198
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSedation ON PatientDemographics.visit_id = ObsICUSedation.visit_id
LEFT OUTER JOIN
(
SELECT 
	cname.name as ICUSurgery, 
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 164190
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSurgery ON PatientDemographics.visit_id = ObsICUSurgery.visit_id
LEFT OUTER JOIN
(
SELECT 
    group_concat(obs.value_numeric separator ', ') as ICU1stHeartRate, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
WHERE 
    enc.encounter_type = 13 
    AND obs.voided = 0
    AND obs.concept_id = 164196
GROUP BY v.visit_id
) AS ObsICU1stHeartRate ON PatientDemographics.visit_id = ObsICU1stHeartRate.visit_id
LEFT OUTER JOIN
(
SELECT 
	group_concat(obs.value_numeric separator ', ') as ICU1stGCSscore, 
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
WHERE 
	  enc.encounter_type = 13 
      AND obs.voided = 0
	  AND obs.concept_id = 164197
GROUP BY v.visit_id
) AS ObsICU1stGCSscore ON PatientDemographics.visit_id = ObsICU1stGCSscore.visit_id
LEFT OUTER JOIN
(
SELECT 
	group_concat(cname.name separator ', ') AS InpatientService,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
WHERE enc.encounter_type = 13 
	  AND obs.concept_id = 161630
      AND obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
GROUP BY v.visit_id
) AS ObsInpatientService ON PatientDemographics.visit_id = ObsInpatientService.visit_id
LEFT OUTER JOIN
(
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
) AS ObsDischargeDiagnosis ON PatientDemographics.visit_id = ObsDischargeDiagnosis.visit_id
WHERE
	(PatientDemographics.DOA BETWEEN CAST( $P{beginDate} AS DATE) AND CAST( $P{endDate} AS DATE))
    AND (ObsICUStay.ICUStay = 'Yes')
GROUP BY PatientDemographics.visit_id
ORDER BY PatientDemographics.DOA asc
