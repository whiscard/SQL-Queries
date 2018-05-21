SELECT 
    coalesce(obsdate, cal_table.datefield) as calendar,
    coalesce(diag.name,'No Diagnosis') as diagnosis,
    coalesce(diag.value_coded,NULL) AS NoOfDiagnosis

FROM
	(
    SELECT
	distinct(per_table.person_id)
	FROM 
	person as per_table
	LEFT JOIN obs as obs_table on per_table.person_id = obs_table.person_id
	where (timestampdiff(year, per_table.birthdate,obs_table.obs_datetime) <=5) 
    AND (date(obs_table.obs_datetime) BETWEEN '2015-07-01' AND '2015-07-31')
    ) as bday
    INNER JOIN
    (
    SELECT
    date(obs_table.obs_datetime) as obsdate, cname.name, obs_table.value_coded, obs_table.person_id
    FROM
    obs as obs_table
	LEFT JOIN concept_name as cname ON obs_table.value_coded = cname.concept_id
	AND (cname.concept_name_type = "FULLY_SPECIFIED"
	AND cname.locale = "en")
	LEFT JOIN concept as concpt ON cname.concept_id = concpt.concept_id
	AND concpt.class_id = 4
    where (date(obs_table.obs_datetime) BETWEEN '2015-07-01' AND '2015-07-31') AND 
    obs_table.value_coded NOT IN (159393,159943,159944,159392)
    ) as diag on diag.person_id=bday.person_id 
    RIGHT JOIN
    calendar as cal_table ON diag.obsdate = cal_table.datefield
	 
where (cal_table.datefield BETWEEN '2015-07-01' AND '2015-07-31')
