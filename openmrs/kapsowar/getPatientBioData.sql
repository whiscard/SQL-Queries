SELECT
    pi.identifier FileNumber,
    pn.given_name GivenName,
    pn.middle_name MiddleName,
    pn.family_name FamilyName,
    p.gender Sex,
    CASE
	  WHEN p.birthdate IS NOT NULL THEN p.birthdate
	  WHEN p.birthdate_estimated = 0 THEN ""
	  ELSE p.birthdate_estimated
    END AS birth_date,
    PhoneNumber.value PhoneNumber,
    a.address1 Address,
    a.city_village City,
    a.state_province Province,
    a.county_district District,
    AccountType.value AccountType,
    MembershipNo.value MembershipNo

FROM
    patient pt INNER JOIN person p ON
        pt.patient_id = p.person_id
    INNER JOIN person_name pn ON
        pn.person_id = p.person_id
    LEFT OUTER JOIN person_address a ON
        p.person_id = a.person_id
    LEFT OUTER JOIN person_attribute PhoneNumber ON
        p.person_id = PhoneNumber.person_id
            AND
        PhoneNumber.person_attribute_type_id = 8
    LEFT OUTER JOIN patient_identifier pi ON
        pt.patient_id = pi.patient_id
            AND
        pi.identifier_type = 4
    LEFT OUTER JOIN person_attribute AccountType ON
        p.person_id = AccountType.person_id
            AND
        AccountType.person_attribute_type_id = 28
    LEFT OUTER JOIN person_attribute MembershipNo ON
        p.person_id = MembershipNo.person_id
            AND
        MembershipNo.person_attribute_type_id = 15
where pt.voided = 0;
