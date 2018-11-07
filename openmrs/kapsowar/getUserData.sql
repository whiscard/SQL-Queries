SELECT
    pn.given_name GivenName,
    pn.middle_name MiddleName,
    pn.family_name FamilyName,
    p.gender Sex

FROM
    users user INNER JOIN person p ON
        user.person_id = p.person_id
    INNER JOIN person_name pn ON
        pn.person_id = p.person_id
WHERE user.retired = 0;
