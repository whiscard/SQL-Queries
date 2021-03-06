SET foreign_key_checks = 0; 
TRUNCATE TABLE obs; 
DELETE FROM encounter where patient_id not in (44,45); 
DELETE FROM patient_identifier where patient_id not in (44,45);
DELETE FROM person_address where person_id not in (select person_id from users) 
and person_id not in (44,45) and person_id in (select patient_id from patient);
DELETE FROM person_attribute where person_id not in (select person_id from users) 
and person_id not in (44,45) and person_id in (select patient_id from patient);
DELETE FROM person_name where person_id not in (select person_id from users) 
and person_id not in (44,45) and person_id in (select patient_id from patient);
DELETE FROM person where person_id not in (select person_id from users) 
and person_id not in (44,45) and person_id in (select patient_id from patient);
DELETE FROM patient where patient_id not in (44,45); 
DELETE FROM visit where patient_id not in (44,45);  
TRUNCATE TABLE cashier_bill; 
TRUNCATE TABLE cashier_bill_line_item; 
TRUNCATE TABLE cashier_bill_payment; 
TRUNCATE TABLE cashier_bill_payment_attribute;
UPDATE `idgen_seq_id_gen` SET `next_sequence_value`='100000' WHERE `id`='2';
DELETE FROM idgen_log_entry where source =2;
DELETE FROM inv_stock_operation where patient_id not in (44,45);
DELETE FROM inv_transaction where patient_id not in (44,45);
SET foreign_key_checks = 1;