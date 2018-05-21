SELECT obs.encounter_id, obs.obs_datetime, obs.obs_group_id, obs.concept_id, cnConceptID.name, obs.value_coded, cnValueCoded.name, obs.value_numeric, obs.value_text
FROM obs obs
left join concept_name cnConceptID on obs.concept_id = cnConceptID.concept_id
  AND cnConceptID.locale = "en"
  AND cnConceptID.concept_name_type = "FULLY_SPECIFIED"
left join concept_name cnValueCoded on obs.value_coded = cnConceptID.concept_id
  AND cnValueCoded.locale = "en"
  AND cnValueCoded.concept_name_type = "FULLY_SPECIFIED"
left join concept c on cnValueCoded.concept_id = c.concept_id
WHERE encounter_id = 764
ORDER BY obs_id asc;

SELECT
    PatientDemographics.visit_id,
    ObsCompleteAuditData.CompleteAuditData,
    ObsICUStay.ICUStay,
    PatientDemographics.PatientName,
    PatientDemographics.HospID,
    PatientDemographics.Age,
    PatientDemographics.Gender,
    PatientDemographics.DOA,
    PatientDemographics.DOD,
    datediff(PatientDemographics.DOD,PatientDemographics.DOA) AS 'LOS (DAYS)',
    ObsDeathHospital.DeathHospital,
    ObsDischargeDiagnosis.DischargeDiagnosis,
    ObsWardStay.WardStay,
    ObsHDUStay.HDUStay,
    ObsHDUCoMngt.HDUCoMngt,
    ObsPreOP.PreOP,
    ObsPalliativeConsult.PalliativeConsult,
    ObsHIV.HIV,
    ObsCD4.CD4,
    ObsPatientDiabetic.PatientDiabetic,
    ObsA1c.A1c,
    ObsICUSurgery.ICUSurgery,
    ObsICUMechanicalventilation.ICUMechanicalventilation,
    ObsICUReceivedvaospressors.ICUReceivedvaospressors,
    ObsICUInfection.ICUInfection,
    ObsICU1stSBP.ICU1stSBP,
    ObsICU1stMAP.ICU1stMAP,
    ObsICU1stHeartRate.ICU1stHeartRate,
    ObsICU1stGCSscore.ICU1stGCSscore,
    ObsICUSedation.ICUSedation,
    ObsICUIntubated.ICUIntubated,
    ObsICU1stRespiratoryRate.ICU1stRespiratoryRate
FROM
(
SELECT
	concat(ifnull(person_name.given_name,''), ' ', ifnull(person_name.middle_name,''), ' ', ifnull(person_name.family_name,'')) AS PatientName,
	patient_identifier.identifier AS HospID,
	visit.date_stopped AS stopped,
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
    patient_identifier.identifier_type = 4
GROUP BY visit.visit_id
) AS PatientDemographics
LEFT OUTER JOIN
(
SELECT
	group_concat(cname.name separator ', ') AS Location,
    ca_ward.answer_concept as Ward,
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept completeAuditQn ON obs.concept_id = completeAuditQn.concept_id
    AND completeAuditQn.uuid = '98f0f043-bdb1-40c6-8c81-6a094056e981'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsCompleteAuditData ON PatientDemographics.visit_id = ObsCompleteAuditData.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as DeathHospital,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept DeathHospitalQn ON obs.concept_id = DeathHospitalQn.concept_id
    AND DeathHospitalQn.uuid = 'ec559b53-8cc9-4b54-a34e-95a605919365'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsDeathHospital ON PatientDemographics.visit_id = ObsDeathHospital.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as PalliativeConsult,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PalliativeConsultQn ON obs.concept_id = PalliativeConsultQn.concept_id
    AND PalliativeConsultQn.uuid = 'a9ae21a2-2631-49d6-928c-d23001812729'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPalliativeConsult ON PatientDemographics.visit_id = ObsPalliativeConsult.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as PreOP,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PreOPQn ON obs.concept_id = PreOPQn.concept_id
    AND PreOPQn.uuid = 'eadfe47c-7988-42ea-97d0-e21ce71db7e0'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPreOP ON PatientDemographics.visit_id = ObsPreOP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as HDUStay,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept HDUStayQn ON obs.concept_id = HDUStayQn.concept_id
    AND HDUStayQn.uuid = '46d4283e-3275-4c6e-9d52-cfd858889f4b'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsHDUStay ON PatientDemographics.visit_id = ObsHDUStay.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as HDUCoMngt,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept HDUCoMngtQn ON obs.concept_id = HDUCoMngtQn.concept_id
    AND HDUCoMngtQn.uuid = 'dd61d87f-3398-46c2-8108-00db2e49bab6'
WHERE
	  obs.voided = 0
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
GROUP BY v.visit_id
) AS ObsHIV ON PatientDemographics.visit_id = ObsHIV.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') AS CD4,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '5497AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PatientDiabeticQn ON obs.concept_id = PatientDiabeticQn.concept_id
    AND PatientDiabeticQn.uuid = 'a424ed50-5f94-4296-a91c-73ebbc1ccca1'
WHERE
	  obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '159644AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept WardStayQn ON obs.concept_id = WardStayQn.concept_id
    AND WardStayQn.uuid = '59073230-e0d9-4cbc-bebc-4bf91a42f3bb'
WHERE
	  obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUStayQn ON obs.concept_id = ICUStayQn.concept_id
    AND ICUStayQn.uuid = '9446f7aa-7a1c-4246-a0a5-1ebc3560a0e0'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUStay ON PatientDemographics.visit_id = ObsICUStay.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUMechanicalventilation,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUMechanicalventilationQn ON obs.concept_id = ICUMechanicalventilationQn.concept_id
    AND ICUMechanicalventilationQn.uuid = '99f47aa5-827c-4472-9884-fbbc094f70bd'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUMechanicalventilation ON PatientDemographics.visit_id = ObsICUMechanicalventilation.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUReceivedvaospressors,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUReceivedvaospressorsQn ON obs.concept_id = ICUReceivedvaospressorsQn.concept_id
    AND ICUReceivedvaospressorsQn.uuid = '611cfa95-0685-4c76-bf9c-981647a085e6'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUReceivedvaospressors ON PatientDemographics.visit_id = ObsICUReceivedvaospressors.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUInfection,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUInfectionQn ON obs.concept_id = ICUInfectionQn.concept_id
    AND ICUInfectionQn.uuid = '8284a6a3-0445-4a23-96cd-8c6767397051'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUInfection ON PatientDemographics.visit_id = ObsICUInfection.visit_id
LEFT OUTER JOIN
(
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
) AS ObsICU1stSBP ON PatientDemographics.visit_id = ObsICU1stSBP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICU1stMAP,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICU1stMAPQn ON obs.concept_id = ICU1stMAPQn.concept_id
    AND ICU1stMAPQn.uuid = '0b19946c-63a6-41e8-b3af-a87fc6addab4'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICU1stMAP ON PatientDemographics.visit_id = ObsICU1stMAP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUSedation,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUSedationQn ON obs.concept_id = ICUSedationQn.concept_id
    AND ICUSedationQn.uuid = '7cccf308-edca-4c3e-afde-e7a3f1155ec6'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSedation ON PatientDemographics.visit_id = ObsICUSedation.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUSurgery,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUSurgeryQn ON obs.concept_id = ICUSurgeryQn.concept_id
    AND ICUSurgeryQn.uuid = '8b1d25f9-2f2e-4dfa-a5a1-87e2f7a3bb52'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSurgery ON PatientDemographics.visit_id = ObsICUSurgery.visit_id
LEFT OUTER JOIN
(
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
GROUP BY v.visit_id
) AS ObsICU1stHeartRate ON PatientDemographics.visit_id = ObsICU1stHeartRate.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') as ICU1stGCSscore,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '99659fa6-fe39-41d7-ac6b-f183d9231310'
WHERE
      obs.voided = 0
GROUP BY v.visit_id
) AS ObsICU1stGCSscore ON PatientDemographics.visit_id = ObsICU1stGCSscore.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(cname.name separator ', ') AS InpatientService,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept InpatientServiceQn ON obs.concept_id = InpatientServiceQn.concept_id
    AND InpatientServiceQn.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
GROUP BY v.visit_id
) AS ObsInpatientService ON PatientDemographics.visit_id = ObsInpatientService.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUIntubated,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUIntubatedQn ON obs.concept_id = ICUIntubatedQn.concept_id
    AND ICUIntubatedQn.uuid = '8b6e4154-006b-4991-ab18-96c1c5357bf3'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUIntubated ON PatientDemographics.visit_id = ObsICUIntubated.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') as ICU1stRespiratoryRate,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '5242AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
GROUP BY v.visit_id
) AS ObsICU1stRespiratoryRate ON PatientDemographics.visit_id = ObsICU1stRespiratoryRate.visit_id
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
	(CAST(PatientDemographics.stopped AS DATE) BETWEEN CAST( '2018-05-19' AS DATE) AND CAST( '2018-05-19' AS DATE))
    AND (ObsWardStay.WardStay = 'Yes' OR ObsHDUStay.HDUStay = 'Yes')
GROUP BY PatientDemographics.visit_id
ORDER BY PatientDemographics.DOA asc;

SELECT
    PatientDemographics.visit_id,
    ObsCompleteAuditData.CompleteAuditData,
    ObsICUStay.ICUStay,
    PatientDemographics.PatientName,
    PatientDemographics.HospID,
    PatientDemographics.Age,
    PatientDemographics.Gender,
    PatientDemographics.DOA,
    PatientDemographics.DOD,
    datediff(PatientDemographics.DOD,PatientDemographics.DOA) AS 'LOS (DAYS)',
    ObsDeathHospital.DeathHospital,
    ObsDischargeDiagnosis.DischargeDiagnosis,
    ObsWardStay.WardStay,
    ObsHDUStay.HDUStay,
    ObsHDUCoMngt.HDUCoMngt,
    ObsPreOP.PreOP,
    ObsPalliativeConsult.PalliativeConsult,
    ObsHIV.HIV,
    ObsCD4.CD4,
    ObsPatientDiabetic.PatientDiabetic,
    ObsA1c.A1c,
    ObsICUSurgery.ICUSurgery,
    ObsICUMechanicalventilation.ICUMechanicalventilation,
    ObsICUReceivedvaospressors.ICUReceivedvaospressors,
    ObsICUInfection.ICUInfection,
    ObsICU1stSBP.ICU1stSBP,
    ObsICU1stMAP.ICU1stMAP,
    ObsICU1stHeartRate.ICU1stHeartRate,
    ObsICU1stGCSscore.ICU1stGCSscore,
    ObsICUSedation.ICUSedation,
    ObsICUIntubated.ICUIntubated,
    ObsICU1stRespiratoryRate.ICU1stRespiratoryRate
FROM
(
SELECT
	concat(ifnull(person_name.given_name,''), ' ', ifnull(person_name.middle_name,''), ' ', ifnull(person_name.family_name,'')) AS PatientName,
	patient_identifier.identifier AS HospID,
	visit.date_stopped AS stopped,
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
    patient_identifier.identifier_type = 4
GROUP BY visit.visit_id
) AS PatientDemographics
LEFT OUTER JOIN
(
SELECT
	group_concat(cname.name separator ', ') AS Location,
    ca_ward.answer_concept as Ward,
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept completeAuditQn ON obs.concept_id = completeAuditQn.concept_id
    AND completeAuditQn.uuid = '98f0f043-bdb1-40c6-8c81-6a094056e981'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsCompleteAuditData ON PatientDemographics.visit_id = ObsCompleteAuditData.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as DeathHospital,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept DeathHospitalQn ON obs.concept_id = DeathHospitalQn.concept_id
    AND DeathHospitalQn.uuid = 'ec559b53-8cc9-4b54-a34e-95a605919365'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsDeathHospital ON PatientDemographics.visit_id = ObsDeathHospital.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as PalliativeConsult,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PalliativeConsultQn ON obs.concept_id = PalliativeConsultQn.concept_id
    AND PalliativeConsultQn.uuid = 'a9ae21a2-2631-49d6-928c-d23001812729'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPalliativeConsult ON PatientDemographics.visit_id = ObsPalliativeConsult.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as PreOP,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PreOPQn ON obs.concept_id = PreOPQn.concept_id
    AND PreOPQn.uuid = 'eadfe47c-7988-42ea-97d0-e21ce71db7e0'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsPreOP ON PatientDemographics.visit_id = ObsPreOP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as HDUStay,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept HDUStayQn ON obs.concept_id = HDUStayQn.concept_id
    AND HDUStayQn.uuid = '46d4283e-3275-4c6e-9d52-cfd858889f4b'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsHDUStay ON PatientDemographics.visit_id = ObsHDUStay.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as HDUCoMngt,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept HDUCoMngtQn ON obs.concept_id = HDUCoMngtQn.concept_id
    AND HDUCoMngtQn.uuid = 'dd61d87f-3398-46c2-8108-00db2e49bab6'
WHERE
	  obs.voided = 0
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
GROUP BY v.visit_id
) AS ObsHIV ON PatientDemographics.visit_id = ObsHIV.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') AS CD4,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '5497AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept PatientDiabeticQn ON obs.concept_id = PatientDiabeticQn.concept_id
    AND PatientDiabeticQn.uuid = 'a424ed50-5f94-4296-a91c-73ebbc1ccca1'
WHERE
	  obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '159644AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept WardStayQn ON obs.concept_id = WardStayQn.concept_id
    AND WardStayQn.uuid = '59073230-e0d9-4cbc-bebc-4bf91a42f3bb'
WHERE
	  obs.voided = 0
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
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUStayQn ON obs.concept_id = ICUStayQn.concept_id
    AND ICUStayQn.uuid = '9446f7aa-7a1c-4246-a0a5-1ebc3560a0e0'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUStay ON PatientDemographics.visit_id = ObsICUStay.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUMechanicalventilation,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUMechanicalventilationQn ON obs.concept_id = ICUMechanicalventilationQn.concept_id
    AND ICUMechanicalventilationQn.uuid = '99f47aa5-827c-4472-9884-fbbc094f70bd'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUMechanicalventilation ON PatientDemographics.visit_id = ObsICUMechanicalventilation.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUReceivedvaospressors,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUReceivedvaospressorsQn ON obs.concept_id = ICUReceivedvaospressorsQn.concept_id
    AND ICUReceivedvaospressorsQn.uuid = '611cfa95-0685-4c76-bf9c-981647a085e6'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUReceivedvaospressors ON PatientDemographics.visit_id = ObsICUReceivedvaospressors.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUInfection,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUInfectionQn ON obs.concept_id = ICUInfectionQn.concept_id
    AND ICUInfectionQn.uuid = '8284a6a3-0445-4a23-96cd-8c6767397051'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUInfection ON PatientDemographics.visit_id = ObsICUInfection.visit_id
LEFT OUTER JOIN
(
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
) AS ObsICU1stSBP ON PatientDemographics.visit_id = ObsICU1stSBP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICU1stMAP,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICU1stMAPQn ON obs.concept_id = ICU1stMAPQn.concept_id
    AND ICU1stMAPQn.uuid = '0b19946c-63a6-41e8-b3af-a87fc6addab4'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICU1stMAP ON PatientDemographics.visit_id = ObsICU1stMAP.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUSedation,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUSedationQn ON obs.concept_id = ICUSedationQn.concept_id
    AND ICUSedationQn.uuid = '7cccf308-edca-4c3e-afde-e7a3f1155ec6'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSedation ON PatientDemographics.visit_id = ObsICUSedation.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUSurgery,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUSurgeryQn ON obs.concept_id = ICUSurgeryQn.concept_id
    AND ICUSurgeryQn.uuid = '8b1d25f9-2f2e-4dfa-a5a1-87e2f7a3bb52'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUSurgery ON PatientDemographics.visit_id = ObsICUSurgery.visit_id
LEFT OUTER JOIN
(
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
GROUP BY v.visit_id
) AS ObsICU1stHeartRate ON PatientDemographics.visit_id = ObsICU1stHeartRate.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') as ICU1stGCSscore,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '99659fa6-fe39-41d7-ac6b-f183d9231310'
WHERE
      obs.voided = 0
GROUP BY v.visit_id
) AS ObsICU1stGCSscore ON PatientDemographics.visit_id = ObsICU1stGCSscore.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(cname.name separator ', ') AS InpatientService,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept InpatientServiceQn ON obs.concept_id = InpatientServiceQn.concept_id
    AND InpatientServiceQn.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
GROUP BY v.visit_id
) AS ObsInpatientService ON PatientDemographics.visit_id = ObsInpatientService.visit_id
LEFT OUTER JOIN
(
SELECT
	cname.name as ICUIntubated,
    v.visit_id
FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept_name cname ON obs.value_coded = cname.concept_id
    AND cname.locale = "en"
	INNER JOIN concept c ON cname.concept_id = c.concept_id
    INNER JOIN concept ICUIntubatedQn ON obs.concept_id = ICUIntubatedQn.concept_id
    AND ICUIntubatedQn.uuid = '8b6e4154-006b-4991-ab18-96c1c5357bf3'
WHERE
	  obs.voided = 0
	  AND cname.concept_name_type = "FULLY_SPECIFIED"
) AS ObsICUIntubated ON PatientDemographics.visit_id = ObsICUIntubated.visit_id
LEFT OUTER JOIN
(
SELECT
	group_concat(obs.value_numeric separator ', ') as ICU1stRespiratoryRate,
    v.visit_id
FROM obs obs
    INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
    INNER JOIN encounter_type enc_type ON enc.encounter_type = enc_type.encounter_type_id
    AND enc_type.uuid = '7dc1632c-f947-474f-b92c-7add68019aec'
	INNER JOIN visit v on enc.visit_id = v.visit_id
    INNER JOIN concept c ON c.concept_id = obs.concept_id
    AND c.uuid = '5242AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
WHERE
      obs.voided = 0
GROUP BY v.visit_id
) AS ObsICU1stRespiratoryRate ON PatientDemographics.visit_id = ObsICU1stRespiratoryRate.visit_id
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
	(CAST(PatientDemographics.stopped AS DATE) BETWEEN CAST( '2018-05-19' AS DATE) AND CAST( '2018-05-19' AS DATE))
    AND (ObsWardStay.WardStay = 'Yes' OR ObsHDUStay.HDUStay = 'Yes')
GROUP BY PatientDemographics.visit_id
ORDER BY PatientDemographics.DOA asc;