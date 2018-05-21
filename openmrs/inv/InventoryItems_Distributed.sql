SELECT
CONCAT(patient_person_name.given_name, ' ', patient_person_name.family_name) as PatientName,
inv_item.name as InventoryItemName, 
COUNT(inv_item.name) as NoOfTransactions, 
SUM(ABS(inv_trans.quantity)) as QuantityDistributed
FROM inv_transaction AS inv_trans
	INNER JOIN inv_stock_operation inv_sto
	ON inv_trans.operation_id = inv_sto.stock_operation_id
	INNER JOIN inv_item 
	ON inv_item.item_id = inv_trans.item_id
	LEFT OUTER JOIN patient ON
	inv_trans.patient_id = patient.patient_id
	LEFT OUTER JOIN person patient_person ON
	patient.patient_id = patient_person.person_id
    LEFT OUTER JOIN person_name patient_person_name ON
    patient_person.person_id = patient_person_name.person_id AND
    patient_person_name.preferred = 1
WHERE inv_sto.operation_type_id = 3 AND inv_sto.patient_id IS NOT NULL
AND inv_trans.patient_id = 45 
AND (inv_trans.date_created BETWEEN '2016-03-01' AND '2016-03-31')
GROUP BY inv_item.name;
