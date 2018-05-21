select 
c.character_set_name 
from information_schema.tables as t,
     information_schema.collation_character_set_applicability as c
where c.collation_name = t.table_collation
and t.table_schema = "marira";