-- 1
mysqldump -u alumno27.tana.felipe -p classicmodels > backup_completo.sql


-- 2
delete  provincia
from classicmodels;
 
 -- 3
 mysql -u alumno27.tana.felipe -p classicmodels < backup_completo.sql