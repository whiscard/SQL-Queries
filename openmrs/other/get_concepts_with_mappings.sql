SELECT 
ConceptName.concept_id AS 'CIEL_ID',
ConceptName.Name AS 'CIEL NAME',
ConceptName.ClassName as 'Concept Class',
SNOMED_CT.Code AS 'SNOMED CT',
SNOMED_NP.Code AS 'SNOMED NP',
ICD_10_WHO.Code AS 'ICD-10-WHO',
ICD_10_WHO_2nd.Code AS 'ICD-10-WHO 2nd',
ICD_10_WHO_NP.Code AS 'ICD-10-WHO NP',
ICD_10_WHO_NP2.Code AS 'ICD-10-WHO NP2',
IMO_ProcedureIT.Code AS 'IMO ProcedureIT'

FROM
(
SELECT
	c.concept_id,
    cname.name AS 'Name',
    cclass.name AS 'ClassName'

FROM
    concept c
        INNER JOIN concept_name cname ON c.concept_id = cname.concept_id
			AND cname.locale = 'en'
			AND cname.concept_name_type = 'FULLY_SPECIFIED'
		INNER JOIN concept_class cclass ON c.class_id = cclass.concept_class_id
        
) AS ConceptName
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 1
) AS SNOMED_CT ON ConceptName.concept_id = SNOMED_CT.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 2
) AS SNOMED_NP ON ConceptName.concept_id = SNOMED_NP.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 3
) AS ICD_10_WHO ON ConceptName.concept_id = ICD_10_WHO.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 8
) AS ICD_10_WHO_2nd ON ConceptName.concept_id = ICD_10_WHO_2nd.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 7
) AS ICD_10_WHO_NP ON ConceptName.concept_id = ICD_10_WHO_NP.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 9
) AS ICD_10_WHO_NP2 ON ConceptName.concept_id = ICD_10_WHO_NP2.concept_id
LEFT OUTER JOIN
(
SELECT
	c.concept_id,
    crs.name AS 'Source',
	crt.code AS 'Code'

FROM
    concept c
        INNER JOIN concept_reference_map crm ON c.concept_id = crm.concept_id
        INNER JOIN concept_reference_term crt ON crm.concept_reference_term_id = crt.concept_reference_term_id
        INNER JOIN concept_reference_source crs ON crt.concept_source_id = crs.concept_source_id
        
WHERE
    crs.concept_source_id = 25
) AS IMO_ProcedureIT ON ConceptName.concept_id = IMO_ProcedureIT.concept_id

ORDER BY ConceptName.concept_id asc
