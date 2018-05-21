SELECT
    pi.identifier as FileNumber,
    pn.given_name as GivenName,
    pn.family_name as FamilyName,
    a.address1 as Address,
    a.city_village as City,
    a.state_province as Province,
    a.county_district as District,
    p.birthdate as DateBirth,
    p.gender as Sex,
    (select value from person_attribute where person_attribute_type_id = 4 and person_id=20341) as KinName,
    (select value from person_attribute where person_attribute_type_id = 5 and person_id=20341) as MaritalStatus,
    (select value from person_attribute where person_attribute_type_id = 9 and person_id=20341) as PhoneNumber,
    (select value from person_attribute where person_attribute_type_id = 12 and person_id=20341) as KinRelationship,
    (select value from person_attribute where person_attribute_type_id = 13 and person_id=20341) as KinAddress
    
FROM
    person p 
		INNER JOIN person_name pn ON
        pn.person_id = p.person_id
		INNER JOIN person_address a ON
        p.person_id = a.person_id
		INNER JOIN person_attribute pa ON
        p.person_id = pa.person_id
        INNER JOIN patient_identifier pi ON
        p.person_id = pi.patient_id
		AND
        pi.identifier_type = 3
WHERE
        p.person_id = 20341
LIMIT 1;