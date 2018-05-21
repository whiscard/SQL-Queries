SELECT * from concept_set WHERE concept_set = 160174;
SELECT count(concept_id) from concept_set WHERE concept_set IN (SELECT concept_id from concept_set WHERE concept_set = 160167);