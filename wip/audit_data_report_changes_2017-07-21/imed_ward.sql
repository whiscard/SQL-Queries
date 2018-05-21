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
)