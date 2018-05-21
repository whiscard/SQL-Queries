SELECT
    pi.identifier as FileNumber,
    pn.given_name as GivenName,
    pn.middle_name as MiddleName,
    pn.family_name as FamilyName,
    a.address1 as Address,
    a.city_village as City,
    a.state_province as Province,
    a.county_district as District,
    p.birthdate as DateBirth,
    p.gender as Sex,
    (select value from person_attribute where person_attribute_type_id = 4 and person_id=20796) as KinName,
    (select cn.name from concept_name cn inner join person_attribute pa on cn.concept_id = pa.value AND pa.person_attribute_type_id = 5 where person_id=20796 limit 1) as MaritalStatus,
    (select value from person_attribute where person_attribute_type_id = 9 and person_id=20796) as PhoneNumber,
    (select cn.name from concept_name cn inner join person_attribute pa on cn.concept_id = pa.value AND pa.person_attribute_type_id = 12 where person_id=20796 limit 1) as KinRelationship,
    (select value from person_attribute where person_attribute_type_id = 13 and person_id=20796) as KinAddress
    
FROM
    person p 
		LEFT OUTER JOIN person_name pn ON
        pn.person_id = p.person_id
		LEFT OUTER JOIN person_address a ON
        p.person_id = a.person_id
		LEFT OUTER JOIN person_attribute pa ON
        p.person_id = pa.person_id
        LEFT OUTER JOIN patient_identifier pi ON
        p.person_id = pi.patient_id
		AND
        pi.identifier_type = 3
WHERE
        p.person_id = 20796
LIMIT 1;