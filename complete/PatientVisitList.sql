SELECT
    v.date_started VisitStarted,
    v.date_stopped VisitEnded,
    v.name VisitType,
    pi.identifier FileNumber,
    pn.given_name GivenName,
    pn.family_name FamilyName,
    pa.value PhoneNumber,
    a.address1 Address,
    a.city_village City,
    a.state_province Province,
    a.county_district District
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
        pa.person_attribute_type_id = 9
    LEFT OUTER JOIN patient_identifier pi ON
        pt.patient_id = pi.patient_id
            AND
        pi.identifier_type = 3
    INNER JOIN (
        SELECT visit_id, date_started, date_stopped,patient_id, visit_type.name
        FROM visit INNER JOIN visit_type ON
            visit.visit_type_id = visit_type.visit_type_id
        WHERE
            (date_started BETWEEN '2015-10-01' AND '2015-10-31'
            OR
             date_stopped BETWEEN '2015-10-01' AND '2015-10-31')
        OR
            (date_started <= '2015-10-01'
                AND
            (date_stopped IS NULL OR date_stopped >= '2015-10-31'))
        ) v ON
        v.patient_id = pt.patient_id
ORDER BY v.date_started, pn.family_name