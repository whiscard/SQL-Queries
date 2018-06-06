SELECT
	PatientDemographics.HospID,
	PatientDemographics.FirstName,
	PatientDemographics.LastName,
  PatientDemographics.dateFirstSeen,
  ObsOR1Procedure.OR1Procedure1,
  ObsPostOpDiagnosis.PostOpDiagnosis,
  EncDateOfOperation.DateOfOperation,
	PatientDemographics.birthdate,
	PatientDemographics.Gender,
  ObsOR2Procedure.OR1Procedure2,
  PatientDemographics.clinicLocation,
  PatientDemographics.City,
  surg.operating_surgeon as surgeon,
  surg.surgeon_assistant as surgeon_assistant,
  ObsSpecialityofCase.SpecialityofCase
FROM
(
SELECT
	patient_identifier.identifier AS HospID,
	person_name.given_name AS FirstName,
	person_name.family_name AS LastName,
  dateFirstSeen.value AS dateFirstSeen,
	person.birthdate AS birthdate,
	person.gender AS Gender,
  loc.name AS clinicLocation,
  person_address.city_village as City,
	visit.visit_id
FROM
	visit visit
	INNER JOIN patient patient ON visit.patient_id = patient.patient_id
	INNER JOIN person person ON patient.patient_id = person.person_id
	INNER JOIN person_name person_name ON person.person_id = person_name.person_id
	LEFT JOIN patient_identifier patient_identifier ON patient.patient_id = patient_identifier.patient_id
    AND patient_identifier.identifier_type = 4
  left join person_attribute dateFirstSeen on person.person_id = dateFirstSeen.person_id
    and dateFirstSeen.person_attribute_type_id = 17
  left join encounter enc on patient.patient_id = enc.patient_id
  left join location loc on enc.location_id = loc.location_id
  left join person_address person_address on person.person_id = person_address.person_id

GROUP BY visit.visit_id
) AS PatientDemographics
LEFT OUTER JOIN
(
  SELECT
    cname.name as OR1Procedure1,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = 'c5029fad-bc7f-4678-83b9-5e3120e0ee0a'
  WHERE
	  obs.concept_id IN (164940)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsOR1Procedure ON PatientDemographics.visit_id = ObsOR1Procedure.visit_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as PostOpDiagnosis,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (163035)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsPostOpDiagnosis ON PatientDemographics.visit_id = ObsPostOpDiagnosis.visit_id
LEFT OUTER JOIN
(
  SELECT
	  date(enc.encounter_datetime) as DateOfOperation,
    enc.encounter_id,
    v.visit_id
  FROM encounter enc
	INNER JOIN visit v on enc.visit_id = v.visit_id
  WHERE
	  enc.encounter_type = 16
    AND enc.voided = 0
  GROUP BY v.visit_id
) AS EncDateOfOperation ON PatientDemographics.visit_id = EncDateOfOperation.visit_id
LEFT OUTER JOIN
(
   SELECT
    cname.name as OR1Procedure2,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '560a5ef3-31d5-4d4a-9f38-163ef0d818e1'
  WHERE
	  obs.concept_id IN (164941)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsOR2Procedure ON PatientDemographics.visit_id = ObsOR2Procedure.visit_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as PostOpDiagnosis,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (163035)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsHDUStay ON PatientDemographics.visit_id = ObsHDUStay.visit_id
left outer join (
select
o.patient, o.encounter_id,
max(case o.grouping_concept when 164919 then o.surgeon else '' end) as operating_surgeon,
max(case o.grouping_concept when 163194 then o.surgeon else '' end) as surgeon_assistant,
max(case o.grouping_concept when 163588 then o.surgeon else '' end) as attending_surgeon
from (
select a.obs_id, b.encounter_id, a.patient, a.concept_id as grouping_concept, b.surgeon, b.concept_id as concept_question
from
(select
o.obs_id,e.patient_id as patient,o.concept_id, o.value_text as surgeon, o.obs_group_id, e.encounter_id
from obs o inner join encounter e on e.encounter_id = o.encounter_id and e.voided =0 and e.encounter_type=16
where (o.concept_id = 1473 and o.voided = 0 and o.obs_group_id is not null) or (o.concept_id in (164919,163194, 163588) and o.obs_group_id is null)
) a
inner join
(select
o.obs_id,e.patient_id as patient,o.concept_id, o.value_text as surgeon, o.obs_group_id, e.encounter_id
from obs o inner join encounter e on e.encounter_id = o.encounter_id and e.voided =0 and e.encounter_type=16
where (o.concept_id = 1473 and o.voided = 0 and o.obs_group_id is not null) or (o.concept_id in (164919,163194, 163588) and o.obs_group_id is null)
) b on a.patient = b.patient and a.obs_id = b.obs_group_id
) o
group by o.encounter_id
) surg on surg.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as SpecialityofCase,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (161630)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsSpecialityofCase ON PatientDemographics.visit_id = ObsSpecialityofCase.visit_id

WHERE
	(CAST(EncDateOfOperation.DateOfOperation AS DATE) BETWEEN CAST( '2018-05-19' AS DATE) AND CAST( '2018-05-29' AS DATE))
GROUP BY PatientDemographics.visit_id
ORDER BY EncDateOfOperation.DateOfOperation asc;

SELECT
	PatientDemographics.HospID,
	PatientDemographics.FirstName,
	PatientDemographics.LastName,
  PatientDemographics.dateFirstSeen,
  ObsOR1Procedure.OR1Procedure,
  ObsPostOpDiagnosis.PostOpDiagnosis,
  EncDateOfOperation.DateOfOperation,
	PatientDemographics.birthdate,
	PatientDemographics.Gender,
  ObsOR2Procedure.OR2Procedure,
  PatientDemographics.clinicLocation,
  PatientDemographics.City,
  surg.operating_surgeon as surgeon,
  surg.surgeon_assistant as surgeon_assistant,
  ObsSpecialityofCase.SpecialityofCase
FROM
(
SELECT
	patient_identifier.identifier AS HospID,
	person_name.given_name AS FirstName,
	person_name.family_name AS LastName,
  dateFirstSeen.value AS dateFirstSeen,
	person.birthdate AS birthdate,
	person.gender AS Gender,
  loc.name AS clinicLocation,
  person_address.city_village as City,
	visit.visit_id
FROM
	visit visit
	INNER JOIN patient patient ON visit.patient_id = patient.patient_id
	INNER JOIN person person ON patient.patient_id = person.person_id
	INNER JOIN person_name person_name ON person.person_id = person_name.person_id
	LEFT JOIN patient_identifier patient_identifier ON patient.patient_id = patient_identifier.patient_id
    AND patient_identifier.identifier_type = 4
  left join person_attribute dateFirstSeen on person.person_id = dateFirstSeen.person_id
    and dateFirstSeen.person_attribute_type_id = 17
  left join encounter enc on patient.patient_id = enc.patient_id
  left join location loc on enc.location_id = loc.location_id
  left join person_address person_address on person.person_id = person_address.person_id

GROUP BY visit.visit_id
) AS PatientDemographics
LEFT OUTER JOIN
(
select
  ORProcedure1GroupID.name as OR1Procedure,
  ORProcedure1GroupID.visit_id
from
(
  select
    obsORProcedure1ConceptWithGroupID.value_coded,
    obsORProcedure1ConceptWithGroupID.obs_group_id,
    cname.name,
    v.visit_id
  from obs obsORProcedure1ConceptWithGroupID
    inner join concept_name cname ON obsORProcedure1ConceptWithGroupID.value_coded = cname.concept_id
    and cname.locale = "en"
	  inner join concept c ON cname.concept_id = c.concept_id
    inner join concept ORProcedure1Ans ON obsORProcedure1ConceptWithGroupID.concept_id = ORProcedure1Ans.concept_id
    and ORProcedure1Ans.uuid = '1651AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsORProcedure1ConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsORProcedure1ConceptWithGroupID.voided = 0
    and cname.concept_name_type = "FULLY_SPECIFIED"
) ORProcedure1GroupID
  inner join
(
  select obsORProcedure1obs.concept_id, obsORProcedure1obs.obs_id
  from obs obsORProcedure1obs
  inner join concept ORProcedure1Concept on obsORProcedure1obs.concept_id = ORProcedure1Concept.concept_id
    and ORProcedure1Concept.uuid = 'd681e30a-c152-4dfb-a0f1-a967fc5ffcc5'
  where
    obsORProcedure1obs.voided = 0
 ) ORProcedure1obsID on ORProcedure1GroupID.obs_group_id = ORProcedure1obsID.obs_id
) AS ObsOR1Procedure ON PatientDemographics.visit_id = ObsOR1Procedure.visit_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as PostOpDiagnosis,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (163035)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsPostOpDiagnosis ON PatientDemographics.visit_id = ObsPostOpDiagnosis.visit_id
LEFT OUTER JOIN
(
  SELECT
	  date(enc.encounter_datetime) as DateOfOperation,
    enc.encounter_id,
    v.visit_id
  FROM encounter enc
	INNER JOIN visit v on enc.visit_id = v.visit_id
  WHERE
	  enc.encounter_type = 16
    AND enc.voided = 0
  GROUP BY v.visit_id
) AS EncDateOfOperation ON PatientDemographics.visit_id = EncDateOfOperation.visit_id
LEFT OUTER JOIN
(
select
  ORProcedure2GroupID.name as OR2Procedure,
  ORProcedure2GroupID.visit_id
from
(
  select
    obsORProcedure2ConceptWithGroupID.value_coded,
    obsORProcedure2ConceptWithGroupID.obs_group_id,
    cname.name,
    v.visit_id
  from obs obsORProcedure2ConceptWithGroupID
    inner join concept_name cname ON obsORProcedure2ConceptWithGroupID.value_coded = cname.concept_id
    and cname.locale = "en"
	  inner join concept c ON cname.concept_id = c.concept_id
    inner join concept ORProcedure2Ans ON obsORProcedure2ConceptWithGroupID.concept_id = ORProcedure2Ans.concept_id
    and ORProcedure2Ans.uuid = '1651AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsORProcedure2ConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsORProcedure2ConceptWithGroupID.voided = 0
    and cname.concept_name_type = "FULLY_SPECIFIED"
) ORProcedure2GroupID
  inner join
(
  select obsORProcedure2obs.concept_id, obsORProcedure2obs.obs_id
  from obs obsORProcedure2obs
  inner join concept ORProcedure2Concept on obsORProcedure2obs.concept_id = ORProcedure2Concept.concept_id
    and ORProcedure2Concept.uuid = '5b149b13-4709-4f37-8f63-a183fd0c3511'
  where
    obsORProcedure2obs.voided = 0
 ) ORProcedure2obsID on ORProcedure2GroupID.obs_group_id = ORProcedure2obsID.obs_id
) AS ObsOR2Procedure ON PatientDemographics.visit_id = ObsOR2Procedure.visit_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as PostOpDiagnosis,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (163035)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsHDUStay ON PatientDemographics.visit_id = ObsHDUStay.visit_id
left outer join (
select
o.patient, o.encounter_id,
max(case o.grouping_concept when 164919 then o.surgeon else '' end) as operating_surgeon,
max(case o.grouping_concept when 163194 then o.surgeon else '' end) as surgeon_assistant,
max(case o.grouping_concept when 163588 then o.surgeon else '' end) as attending_surgeon
from (
select a.obs_id, b.encounter_id, a.patient, a.concept_id as grouping_concept, b.surgeon, b.concept_id as concept_question
from
(select
o.obs_id,e.patient_id as patient,o.concept_id, o.value_text as surgeon, o.obs_group_id, e.encounter_id
from obs o inner join encounter e on e.encounter_id = o.encounter_id and e.voided =0 and e.encounter_type=16
where (o.concept_id = 1473 and o.voided = 0 and o.obs_group_id is not null) or (o.concept_id in (164919,163194, 163588) and o.obs_group_id is null)
) a
inner join
(select
o.obs_id,e.patient_id as patient,o.concept_id, o.value_text as surgeon, o.obs_group_id, e.encounter_id
from obs o inner join encounter e on e.encounter_id = o.encounter_id and e.voided =0 and e.encounter_type=16
where (o.concept_id = 1473 and o.voided = 0 and o.obs_group_id is not null) or (o.concept_id in (164919,163194, 163588) and o.obs_group_id is null)
) b on a.patient = b.patient and a.obs_id = b.obs_group_id
) o
group by o.encounter_id
) surg on surg.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
  SELECT
	  cname.name as SpecialityofCase,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  LEFT OUTER JOIN concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	AND cname.concept_name_type = "FULLY_SPECIFIED"
	LEFT OUTER JOIN concept c ON cname.concept_id = c.concept_id
  and c.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.concept_id IN (161630)
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsSpecialityofCase ON PatientDemographics.visit_id = ObsSpecialityofCase.visit_id

WHERE
	(CAST(EncDateOfOperation.DateOfOperation AS DATE) BETWEEN CAST( $P{begin_TreatmentDate} AS DATE) AND CAST($P{end_TreatmentDate} AS DATE))
GROUP BY PatientDemographics.visit_id
ORDER BY EncDateOfOperation.DateOfOperation asc;