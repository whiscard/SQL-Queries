SET foreign_key_checks = 0;
delete from obs where creator = 2 order by obs_datetime asc;
delete from encounter where creator = 2;
delete from patient_identifier where creator = 2;
delete from person_address where creator = 2 and person_id not in (select person_id from users);
delete from person_name where creator = 2 and person_id not in (select person_id from users)
and person_id not in (select person_id from provider);
delete from person where creator = 2 and person_id not in (select person_id from users)
and person_id not in (select person_id from provider);
delete from patient where creator = 2 and patient_id not in (select person_id from users)
and patient_id not in (select person_id from provider);
delete from visit where creator = 2;
delete from idgen_log_entry where source = 1 and comment = 'DemoData';
SET foreign_key_checks = 1;
