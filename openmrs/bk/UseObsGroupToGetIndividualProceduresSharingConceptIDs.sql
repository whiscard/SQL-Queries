select ORProcedure1GroupID.name as OR1Procedure
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
 ) ORProcedure1obsID on ORProcedure1GroupID.obs_group_id = ORProcedure1obsID.obs_id;


select ORProcedure2GroupID.name as OR2Procedure
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
 ) ORProcedure2obsID on ORProcedure2GroupID.obs_group_id = ORProcedure2obsID.obs_id;


select ORProcedure3GroupID.name as OR3Procedure3
from
(
  select
    obsORProcedure3ConceptWithGroupID.value_coded,
    obsORProcedure3ConceptWithGroupID.obs_group_id,
    cname.name,
    v.visit_id
  from obs obsORProcedure3ConceptWithGroupID
    inner join concept_name cname ON obsORProcedure3ConceptWithGroupID.value_coded = cname.concept_id
    and cname.locale = "en"
	  inner join concept c ON cname.concept_id = c.concept_id
    inner join concept ORProcedure3Ans ON obsORProcedure3ConceptWithGroupID.concept_id = ORProcedure3Ans.concept_id
    and ORProcedure3Ans.uuid = '1651AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
    inner join encounter enc on obsORProcedure3ConceptWithGroupID.encounter_id = enc.encounter_id
	  inner join visit v on enc.visit_id = v.visit_id
  where
	  obsORProcedure3ConceptWithGroupID.voided = 0
    and cname.concept_name_type = "FULLY_SPECIFIED"
) ORProcedure3GroupID
  inner join
(
  select obsORProcedure3obs.concept_id, obsORProcedure3obs.obs_id
  from obs obsORProcedure3obs
  inner join concept ORProcedure3Concept on obsORProcedure3obs.concept_id = ORProcedure3Concept.concept_id
    and ORProcedure3Concept.uuid = '91d73d83-c954-4415-b22a-7a8b9cd4b319'
  where
    obsORProcedure3obs.voided = 0
 ) ORProcedure3obsID on ORProcedure3GroupID.obs_group_id = ORProcedure3obsID.obs_id;

select
  SurgeonNameGroupID.value_text as OperatingSurgeon,
  SurgeonNameGroupID.visit_id
from
(
  select
    obsSurgeonNameConceptWithGroupID.value_text,
    obsSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id
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
 ) SurgeonNameobsID on SurgeonNameGroupID.obs_group_id = SurgeonNameobsID.obs_id;



select
  AssistantSurgeonNameGroupID.value_text as AssistantSurgeon,
  AssistantSurgeonNameGroupID.visit_id
from
(
  select
    obsAssistantSurgeonNameConceptWithGroupID.value_text,
    obsAssistantSurgeonNameConceptWithGroupID.obs_group_id,
    v.visit_id
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
 ) AssistantSurgeonNameobsID on AssistantSurgeonNameGroupID.obs_group_id = AssistantSurgeonNameobsID.obs_id;