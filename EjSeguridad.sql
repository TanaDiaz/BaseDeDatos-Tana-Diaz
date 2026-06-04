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