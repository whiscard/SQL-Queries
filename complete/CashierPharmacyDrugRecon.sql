SELECT
	pi.identifier AS FileNumber,
    pn.given_name AS PatientFirstName,
    pn.middle_name AS PatientMiddleName,
    pn.family_name AS PatientFamilyName,
	inv.name AS DrugName,
    cbi.quantity AS DrugQuantityIssued,
    cashier_person_name.given_name AS CashierFirstName,
	cashier_person_name.family_name AS CashierFamilyName
    
FROM
	cashier_bill_line_item cbi 
	INNER JOIN inv_item inv ON
    cbi.item_id = inv.item_id
    INNER JOIN cashier_bill cb ON
    cbi.bill_id = cb.bill_id
    INNER JOIN person_name pn ON
    cb.patient_id = pn.person_id
    INNER JOIN patient_identifier pi ON
	cb.patient_id = pi.patient_id
	AND
    pi.identifier_type = 3
    INNER JOIN provider pv ON
    cb.provider_id = pv.provider_id
    INNER JOIN person cashier_person ON
	pv.person_id = cashier_person .person_id
	LEFT OUTER JOIN person_name cashier_person_name ON
	cashier_person.person_id = cashier_person_name.person_id AND
	cashier_person_name.preferred = 1
    
WHERE 
	date_format(cbi.date_created, '%Y-%m-%d') = '2015-11-10'
    AND inv.department_id = 2;