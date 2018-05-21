SELECT
    pi.identifier FileNumber,
    pn.given_name GivenName,
    pn.family_name FamilyName,
    a.address1 Address,
    a.city_village City,
    a.state_province Province,
    a.county_district District,
    p.birthdate DateBirth,
    p.gender Sex,
    pa.value KinName,
    pa.value MaritalStatus,
    pa.value PhoneNumber,
    pa.value KinRelationship,
    pa.value KinAddress
    
FROM
    patient pt INNER JOIN person p ON
        pt.patient_id = p.person_id
    INNER JOIN person_name pn ON
        pn.person_id = p.person_id
    LEFT OUTER JOIN person_address a ON
        p.person_id = a.person_id
    LEFT OUTER JOIN person_attribute pa ON
        p.person_id = pa.person_id
            AND
        (pa.person_attribute_type_id IN (4,5,9,12,13))
	LEFT OUTER JOIN patient_identifier pi ON
        pt.patient_id = pi.patient_id
            AND
        pi.identifier_type = 3
    WHERE
        pi.identifier = 699876;