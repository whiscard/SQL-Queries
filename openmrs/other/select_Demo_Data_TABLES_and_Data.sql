select * from obs where creator = 2 order by obs_datetime asc;
select * from encounter where creator = 2;
select * from patient_identifier where creator = 2;
select * from person_address where creator = 2 and person_id not in (select person_id from users);
select * from person_name where creator = 2 and person_id not in (select person_id from users)
and person_id not in (select person_id from provider);
select * from person where creator = 2 and person_id not in (select person_id from users)
and person_id not in (select person_id from provider);
select * from patient where creator = 2 and patient_id not in (select person_id from users)
and patient_id not in (select person_id from provider);
select * from visit where creator = 2;
select * from idgen_log_entry where source = 1 and comment = 'DemoData';

