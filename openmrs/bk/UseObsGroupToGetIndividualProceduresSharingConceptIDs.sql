select ORProcedure1GroupID.name as OR1Procedure1
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


select ORProcedure2.value_coded
from
(
  select obsProcedure2.value_coded, obsProcedure2.obs_group_id
  from obs obsProcedure2
  where concept_id = 1651 and obsProcedure2.voided = 0
) ORProcedure2
  inner join
  (
    select concept_id, obs_id
    from obs obsOR2
    where obsOR2.concept_id = 164986 and obsOR2.voided = 0
  ) obsOR2Procedure2 on ORProcedure2.obs_group_id = obsOR2Procedure2.obs_id;


select ORProcedure3.value_coded
from
(
  select obsProcedure3.value_coded, obsProcedure3.obs_group_id
  from obs obsProcedure3
  where concept_id = 1651 and obsProcedure3.voided = 0
) ORProcedure3
  inner join
  (
    select concept_id, obs_id
    from obs obsOR3
    where obsOR3.concept_id = 164987 and obsOR3.voided = 0
  ) obsOR3Procedure3 on ORProcedure3.obs_group_id = obsOR3Procedure3.obs_id;