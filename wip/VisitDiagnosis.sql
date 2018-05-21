select 
visit.date_started,
patient.patient_id,
person_name.given_name,
person_name.middle_name,
person_name.family_name,
person.gender,
visit_type.name as location,
group_concat(" ",
CASE 
WHEN obs.value_coded is null THEN obs.value_text 
WHEN obs.value_coded IS NOT NULL and obs.value_text is not null then concept_name.name + ", " + obs.value_text 
ELSE concept_name.name END) as diag,
CASE
WHEN person.birthdate IS NOT NULL THEN person.birthdate 
 WHEN person.birthdate_estimated = 0 THEN ""
        ELSE person.birthdate_estimated
    END as birth_date,
person_attribute.value,
CASE 
WHEN person.birthdate IS NOT NULL THEN 
		(CASE 
		WHEN timestampdiff(year, person.birthdate,visit.date_started) > 5 THEN "A" 
		ELSE "C" END)
WHEN person.birthdate_estimated != 0 THEN
		(CASE 
		WHEN timestampdiff(year,person.birthdate_estimated,visit.date_started) > 5 THEN "A" 
		ELSE "C" END)
WHEN person.birthdate IS NOT NULL AND person.birthdate_estimated != 0 THEN
		(CASE 
		WHEN timestampdiff(year,person.birthdate,visit.date_started) > 5 THEN "A" 
		ELSE "C" END)
ELSE "" END as age

    
from visit inner join patient on
visit.patient_id = patient.patient_id
inner join person on
patient.patient_id = person.person_id
inner join person_name on
person.person_id = person_name.person_id 
inner join person_attribute on
person.person_id = person_attribute.person_id
inner join visit_type on
visit.visit_type_id = visit_type.visit_type_id
inner join location on
visit.location_id = location.location_id
inner join obs on
person.person_id = obs.person_id
inner join concept_name on
obs.value_coded = concept_name.concept_id
inner join concept on
concept_name.concept_id = concept.concept_id
WHERE (visit.date_created BETWEEN "2015-01-27"  AND "2015-11-27" )
 and  person_attribute.person_attribute_type_id = 9
 and obs.concept_id = 1284
 and concept_name.locale = "en"
 and concept_name.concept_name_type = "FULLY_SPECIFIED" 
 group by visit.date_started
ORDER BY visit.date_started ASC;