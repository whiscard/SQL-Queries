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
  ObsOperatingSurgeon.OperatingSurgeon as surgeon,
  ObsAssistantSurgeon.AssistantSurgeon as surgeon_assistant,
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
  inner join concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	inner join concept opDiagnosis ON obs.concept_id = opDiagnosis.concept_id
  and opDiagnosis.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.voided = 0
    AND cname.concept_name_type = "FULLY_SPECIFIED"
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
select
  SurgeonNameGroupID.value_text as OperatingSurgeon,
  SurgeonNameGroupID.visit_id,
  SurgeonNameGroupID.encounter_id
from
(
  select
    obsSurgeonNameConceptWithGroupID.value_text,
    obsSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id,
    enc.encounter_id
  from obs obsSurgeonNameConceptWithGroupID
    inner join concept SurgeonName ON obsSurgeonNameConceptWithGroupID.concept_id = SurgeonName.concept_id
    and SurgeonName.uuid = '1473AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsSurgeonNameConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsSurgeonNameConceptWithGroupID.voided = 0
) SurgeonNameGroupID
  inner join
(
  select obsSurgeonName.concept_id, obsSurgeonName.obs_id
  from obs obsSurgeonName
  inner join concept SurgeonNameConcept on obsSurgeonName.concept_id = SurgeonNameConcept.concept_id
    and SurgeonNameConcept.uuid = '164919AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  where
    obsSurgeonName.voided = 0
 ) SurgeonNameobsID on SurgeonNameGroupID.obs_group_id = SurgeonNameobsID.obs_id
) ObsOperatingSurgeon on ObsOperatingSurgeon.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
select
  AssistantSurgeonNameGroupID.value_text as AssistantSurgeon,
  AssistantSurgeonNameGroupID.visit_id,
  AssistantSurgeonNameGroupID.encounter_id
from
(
  select
    obsAssistantSurgeonNameConceptWithGroupID.value_text,
    obsAssistantSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id,
    enc.encounter_id
  from obs obsAssistantSurgeonNameConceptWithGroupID
    inner join concept AssistantSurgeonName ON obsAssistantSurgeonNameConceptWithGroupID.concept_id = AssistantSurgeonName.concept_id
    and AssistantSurgeonName.uuid = '1473AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsAssistantSurgeonNameConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsAssistantSurgeonNameConceptWithGroupID.voided = 0
) AssistantSurgeonNameGroupID
  inner join
(
  select obsAssistantSurgeonName.concept_id, obsAssistantSurgeonName.obs_id
  from obs obsAssistantSurgeonName
  inner join concept AssistantSurgeonNameConcept on obsAssistantSurgeonName.concept_id = AssistantSurgeonNameConcept.concept_id
    and AssistantSurgeonNameConcept.uuid = '269879d8-c629-4c27-b87c-0c341bd80c66'
  where
    obsAssistantSurgeonName.voided = 0
 ) AssistantSurgeonNameobsID on AssistantSurgeonNameGroupID.obs_group_id = AssistantSurgeonNameobsID.obs_id
) ObsAssistantSurgeon on ObsAssistantSurgeon.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
SELECT
	  cname.name as SpecialityofCase,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  inner join concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	inner join concept c ON cname.concept_id = c.concept_id
  inner join concept specialityCase on obs.concept_id = specialityCase.concept_id
  and specialityCase.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
    cname.concept_name_type = "FULLY_SPECIFIED"
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsSpecialityofCase ON PatientDemographics.visit_id = ObsSpecialityofCase.visit_id

WHERE
	(CAST(EncDateOfOperation.DateOfOperation AS DATE) BETWEEN CAST( '2018-05-19' AS DATE) AND CAST( '2018-06-29' AS DATE))
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
  ObsOperatingSurgeon.OperatingSurgeon as surgeon,
  ObsAssistantSurgeon.AssistantSurgeon as surgeon_assistant,
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
  inner join concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	inner join concept opDiagnosis ON obs.concept_id = opDiagnosis.concept_id
  and opDiagnosis.uuid = '163035AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
	  obs.voided = 0
    AND cname.concept_name_type = "FULLY_SPECIFIED"
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
select
  SurgeonNameGroupID.value_text as OperatingSurgeon,
  SurgeonNameGroupID.visit_id,
  SurgeonNameGroupID.encounter_id
from
(
  select
    obsSurgeonNameConceptWithGroupID.value_text,
    obsSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id,
    enc.encounter_id
  from obs obsSurgeonNameConceptWithGroupID
    inner join concept SurgeonName ON obsSurgeonNameConceptWithGroupID.concept_id = SurgeonName.concept_id
    and SurgeonName.uuid = '1473AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsSurgeonNameConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsSurgeonNameConceptWithGroupID.voided = 0
) SurgeonNameGroupID
  inner join
(
  select obsSurgeonName.concept_id, obsSurgeonName.obs_id
  from obs obsSurgeonName
  inner join concept SurgeonNameConcept on obsSurgeonName.concept_id = SurgeonNameConcept.concept_id
    and SurgeonNameConcept.uuid = '164919AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  where
    obsSurgeonName.voided = 0
 ) SurgeonNameobsID on SurgeonNameGroupID.obs_group_id = SurgeonNameobsID.obs_id
) ObsOperatingSurgeon on ObsOperatingSurgeon.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
select
  AssistantSurgeonNameGroupID.value_text as AssistantSurgeon,
  AssistantSurgeonNameGroupID.visit_id,
  AssistantSurgeonNameGroupID.encounter_id
from
(
  select
    obsAssistantSurgeonNameConceptWithGroupID.value_text,
    obsAssistantSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id,
    enc.encounter_id
  from obs obsAssistantSurgeonNameConceptWithGroupID
    inner join concept AssistantSurgeonName ON obsAssistantSurgeonNameConceptWithGroupID.concept_id = AssistantSurgeonName.concept_id
    and AssistantSurgeonName.uuid = '1473AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsAssistantSurgeonNameConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsAssistantSurgeonNameConceptWithGroupID.voided = 0
) AssistantSurgeonNameGroupID
  inner join
(
  select obsAssistantSurgeonName.concept_id, obsAssistantSurgeonName.obs_id
  from obs obsAssistantSurgeonName
  inner join concept AssistantSurgeonNameConcept on obsAssistantSurgeonName.concept_id = AssistantSurgeonNameConcept.concept_id
    and AssistantSurgeonNameConcept.uuid = '269879d8-c629-4c27-b87c-0c341bd80c66'
  where
    obsAssistantSurgeonName.voided = 0
 ) AssistantSurgeonNameobsID on AssistantSurgeonNameGroupID.obs_group_id = AssistantSurgeonNameobsID.obs_id
) ObsAssistantSurgeon on ObsAssistantSurgeon.encounter_id = EncDateOfOperation.encounter_id
LEFT OUTER JOIN
(
SELECT
	  cname.name as SpecialityofCase,
    v.visit_id
  FROM obs obs
	INNER JOIN encounter enc on obs.encounter_id = enc.encounter_id
	INNER JOIN visit v on enc.visit_id = v.visit_id
  inner join concept_name cname ON obs.value_coded = cname.concept_id
  AND cname.locale = "en"
	inner join concept c ON cname.concept_id = c.concept_id
  inner join concept specialityCase on obs.concept_id = specialityCase.concept_id
  and specialityCase.uuid = '161630AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  WHERE
    cname.concept_name_type = "FULLY_SPECIFIED"
    AND obs.voided = 0
  GROUP BY v.visit_id
) AS ObsSpecialityofCase ON PatientDemographics.visit_id = ObsSpecialityofCase.visit_id

WHERE
	(CAST(EncDateOfOperation.DateOfOperation AS DATE) BETWEEN CAST( $P{begin_TreatmentDate} AS DATE) AND CAST($P{end_TreatmentDate} AS DATE))
GROUP BY PatientDemographics.visit_id
ORDER BY EncDateOfOperation.DateOfOperation asc;