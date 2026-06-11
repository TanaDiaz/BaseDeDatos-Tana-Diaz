create user 'analistastock'@'localhost' identified by 'AnalistaStock';
create user 'gestorproductos'@'localhost' identified by 'GestorProductos';
create user 'userreportes'@'localhost' identified by 'UserReportes';
create user 'userdesarrollo'@'localhost' identified by 'UserDesarrollo';
create user 'adminbdd'@'localhost' identified by 'AdminBDD';

create role 'rolstock';
create role 'rolordenes';
create role 'rolreportes';
create role 'roldesarrollo';
create role 'roladmin';

grant select on *.* to 'rolstock';

grant execute on procedure actualizarstock to 'rolstock';
grant execute on procedure reducirprecio to 'rolstock';
grant execute on procedure actualizarprecioporproveedor to 'rolstock';

grant select on orders to 'rolordenes';
grant select on orderdetails to 'rolordenes';

grant execute on procedure borrarorden to 'rolordenes';
grant execute on procedure borrarlineaproductos to 'rolordenes';
grant execute on procedure actualizarcomentarios to 'rolordenes';

grant select on *.* to 'rolreportes';

grant select, insert, update, delete
on *.* to 'roldesarrollo';

grant create routine, alter routine, execute
on *.* to 'roldesarrollo';

grant trigger, event
on *.* to 'roldesarrollo';

grant all privileges
on *.* to 'roladmin';

grant 'rolstock' to 'analistastock'@'localhost';
grant 'rolordenes' to 'gestorproductos'@'localhost';
grant 'rolreportes' to 'userreportes'@'localhost';
grant 'roldesarrollo' to 'userdesarrollo'@'localhost';
grant 'roladmin' to 'adminbdd'@'localhost';

set default role 'rolstock'
to 'analistastock'@'localhost';

set default role 'rolordenes'
to 'gestorproductos'@'localhost';

set default role 'rolreportes'
to 'userreportes'@'localhost';

set default role 'roldesarrollo'
to 'userdesarrollo'@'localhost';

set default role 'roladmin'
to 'adminbdd'@'localhost';

select *
from mysql.role_edges;

select user, host
from mysql.user
where is_role = 'y';

show grants for 'rolstock';
show grants for 'rolordenes';
show grants for 'rolreportes';
show grants for 'roldesarrollo';
show grants for 'roladmin';



3)

grant 'rol_analista_stock' to 'analista_stock'@'localhost';
grant 'rol_gestor_ordenes' to 'gestor_productos'@'localhost';
grant 'rol_gestor_ordenes' to 'analista_ordenes'@'localhost';
grant 'rol_reportes' to 'usuario_reportes'@'localhost';
grant 'rol_desarrollo' to 'desarrollador'@'localhost';
grant 'rol_admin' to 'admin_dba'@'localhost';

alter user 'analista_stock'@'localhost' default role 'rol_analista_stock';
alter user 'gestor_productos'@'localhost' default role 'rol_gestor_ordenes';
alter user 'analista_ordenes'@'localhost' default role 'rol_gestor_ordenes';
alter user 'usuario_reportes'@'localhost' default role 'rol_reportes';
alter user 'desarrollador'@'localhost' default role 'rol_desarrollo';
alter user 'admin_dba'@'localhost' default role 'rol_admin';

show grants for 'analista_stock'@'localhost';
show grants for 'gestor_productos'@'localhost';
show grants for 'analista_ordenes'@'localhost';
show grants for 'usuario_reportes'@'localhost';
show grants for 'desarrollador'@'localhost';
show grants for 'admin_dba'@'localhost';


create user 'empleado_rrhh'@'localhost' identified by 'rrhh123';

grant select (firstname, lastname, jobtitle, officecode) on classicmodels.employees to 'empleado_rrhh'@'localhost';

grant execute on function classicmodels.contarempleados to 'empleado_rrhh'@'localhost';


select firstname, lastname, jobtitle, officecode from classicmodels.employees;

select * from classicmodels.employees;


create user 'operador_stock'@'localhost' identified by 'op123';

grant execute on procedure classicmodels.actualizarstock to 'operador_stock'@'localhost';

call classicmodels.actualizarstock(100, 10);

select * from classicmodels.products;

fcall classicmodels.reducirprecio(100);