SELECT
    cb.receipt_number AS BillReceipt,
    DATE_FORMAT(cbp.date_created, '%Y-%m-%d') AS BillDate,
    pi.identifier AS FileNumber,
    concat_ws(' ', pn.given_name, pn.middle_name, pn.family_name) AS PatientName,
    cbp.amount AS BillAmount,
    CASE 
	WHEN value_reference = '43462' THEN 'KIJABE'
	WHEN value_reference = '21011' THEN 'ACCORD'
	WHEN value_reference = '67200' THEN 'RVA'
        WHEN value_reference = '60052' THEN 'NEW HOPE CHILDRENS CENTER' 
    END AS companyname
    
FROM
    cashier_bill cb
    INNER JOIN cashier_bill_payment cbp ON
    cb.bill_id = cbp.bill_id
    INNER JOIN cashier_bill_payment_attribute cbpa ON
    cbp.bill_payment_id = cbpa.bill_payment_id
    AND cbpa.payment_mode_attribute_type_id = 2
    INNER JOIN person_name pn ON
    cb.patient_id = pn.person_id
    INNER JOIN patient_identifier pi ON
	cb.patient_id = pi.patient_id
	AND
    pi.identifier_type = 3
    
WHERE 
    cbpa.value_reference = '21011' AND
    (cbp.date_created BETWEEN '2016-05-01'  AND '2016-08-31')
