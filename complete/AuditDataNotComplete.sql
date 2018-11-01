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
    patient_identifier.identifier_type = 5
WHERE
    (
    visit.visit_id in
    (
    SELECT
        v.visit_id
    FROM visit v
    WHERE v.date_stopped is not null
      AND v.voided = 0
      AND v.visit_id
      NOT IN
        (select distinct visit_id from encounter where encounter_type = 13)
    )
    )
OR
   (
   visit.visit_id in
   (
   SELECT
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
       AND
       completeAuditQn.uuid = '98f0f043-bdb1-40c6-8c81-6a094056e981'
    WHERE obs.voided = 0
         AND cname.concept_name_type = "FULLY_SPECIFIED"
         AND cname.name = "No")
    )
AND
	(CAST(visit.date_stopped AS DATE) BETWEEN CAST( '2018-09-01' AS DATE) AND CAST( '2018-10-31' AS DATE))
GROUP BY visit.visit_id
ORDER BY visit.date_stopped ASC;
