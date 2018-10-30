SELECT
  PatientDemographics.visit_id,
  PatientDemographics.PatientName,
  PatientDemographics.HospID,
  PatientDemographics.Age,
  PatientDemographics.Gender,
  PatientDemographics.DOA,
  PatientDemographics.DOD
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
    patient_identifier.identifier_type = 5
GROUP BY visit.visit_id
) AS PatientDemographics
INNER JOIN
(
SELECT
  v.visit_id,
  v.patient_id,
  v.date_started,
  v.date_stopped
FROM visit v
WHERE v.date_stopped is not null
  AND v.voided = 0
  AND v.visit_id
    NOT IN
    (
      select distinct visit_id
      from encounter
      where encounter_type = 13
    )
) AS NoAuditDataEnc ON PatientDemographics.visit_id = NoAuditDataEnc.visit_id
WHERE
	(CAST(PatientDemographics.stopped AS DATE) BETWEEN CAST( '2018-10-01' AS DATE) AND CAST( '2018-10-31' AS DATE))
