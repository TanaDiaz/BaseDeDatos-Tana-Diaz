1) delimiter //

create procedure piezasDefectuosasHoy(
in idEmpleado int,
out porcentajeDefectuosas int
)
begin

declare totalpiezas int default 0;
declare piezas int default 0;

declare totaldefectuosas int default 0;
declare defectuosas int default 0;

declare hayFilas boolean default 1;

declare cur cursor for
select rp.total_defectuosos, rp.total_producido
from reporteProduccion rp
join Empleado e on e.id_empleado = rp.id_empleado
join OrdenProduccion op on op.id_empleado = e.id_empleado
where rp.id_empleado = idEmpleado
and op.fecha = currentdate();

declare continue handler for not found set hayFilas = 0;

open cur;

loop_piezas: loop

fetch cur into defectuosas, piezas;

if hayFilas = 0 then
leave loop_piezas;
end if;

set totalpiezas = totalpiezas + piezas;
set totaldefectuosas = totaldefectuosas + defectuosas;

end loop;

if totalpiezas > 0 then
set porcentajeDefectuosas =
(totaldefectuosas * 100) / totalpiezas;
else
set porcentajeDefectuosas = 0;
end if;

close cur;

end //

delimiter ;






















2)delimiter //

create procedure reportesEmpleados()
begin

declare cantReportes int default 0;
declare cantidadReporte int default 0;
declare defectuososReporte int default 0;

declare hayFilas boolean default 1;
declare v_idEmpleado int;

declare cur cursor for
select op.id_empleado
from OrdenProduccion op
where op.fecha = currentdate();

declare continue handler for not found set hayFilas = 0;

open cur;

loop_reporte: loop

fetch cur into v_idEmpleado;

if hayFilas = 0 then
leave loop_reporte;
end if;

select count(*)
into cantReportes
from ReporteProduccion
where id_empleado = v_idEmpleado;

select sum(do.cantidad)
into cantidadReporte
from DetalleOrden do
join OrdenProduccion op
on op.id_orden = do.id_orden
where op.id_empleado = v_idEmpleado
and op.fecha = currentdate();

select sum(do.defectuosos)
into defectuososReporte
from DetalleOrden do
join OrdenProduccion op
on op.id_orden = do.id_orden
where op.id_empleado = v_idEmpleado
and op.fecha = currentdate();

if cantReportes = 0 then

insert into ReporteProduccion
(id_empleado, total_producido, total_defectuosos)
values
(v_idEmpleado, cantidadReporte, defectuososReporte);

else

update ReporteProduccion
set total_producido = cantidadReporte,
total_defectuosos = defectuososReporte
where id_empleado = v_idEmpleado;

end if;

end loop;

close cur;

end //

delimiter ;






3) delimiter //

create procedure revisionProductos(out prodRev varchar(5000))
begin

declare fechaRevision date;
declare listaAuxiliar varchar(5000) default '';

declare hayFilas boolean default 1;

declare v_idProducto int;
declare v_nombre varchar(100);

declare cur cursor for
select id_producto, nombre
from Producto;

declare continue handler for not found set hayFilas = 0;

open cur;

loop_revision: loop

fetch cur into v_idProducto, v_nombre;

if hayFilas = 0 then
leave loop_revision;
end if;

select max(op.fecha)
into fechaRevision
from OrdenProduccion op
join DetalleOrden od
on od.id_orden = op.id_orden
where od.id_producto = v_idProducto;

if fechaRevision is null then

set listaAuxiliar =
concat(listaAuxiliar,
v_nombre,
' -sin revision-, ');

elseif fechaRevision < date_sub(current_date(), interval 1 year) then

set listaAuxiliar =
concat(listaAuxiliar,
v_nombre,
' ',
year(fechaRevision),
', ');

end if;

end loop;

close cur;

set prodRev = listaAuxiliar;

end //

delimiter ;






















4- Crear un stored procedure que devuelva el id del producto con mayor porcentaje de no
defectuosos el día de hoy. No confundir cantidad de no defectuosos con porcentaje de no
defectuosos.

delimiter //
create procedure ProdDefectuosoHoy(out productoMenosDefectuosoHoy int)
begin

declare hayFilas boolean default 1;
declare porcentajeDefectuoso int;
declare totalProducto int;
declare totalDefectuoso int;
declare menosDefectuoso int default 100;
declare idMenosDefectuoso int;
declare  v_idProducto int;

declare cur cursor for
select  do.id_producto from DetalleOrden do
join OrdenProduccion op on op.id_orden = do.id_orden;

declare continue handler for not found set hayFilas = 0;


 open cur;
 loop_defectuosos: loop
 
 fetch cur into v_idProducto;
 
 if hayFilas = 0 then
 leave loop_defectuosos;
 end if;
 
 select.sum(do.cantidad) into totalProducto from DetalleOrden do
 join OrdenProduccion op on op.id_orden = do.id_orden
 where do.id_producto = v_idProducto and op.fecha = currentdate();
 
 select sum(do.defectuosos) into totalDefectuoso from DetalleOrden do
  join OrdenProduccion op on op.id_orden = do.id_orden
 where do.id_producto = v_idProducto and op.fecha = currentdate();
 
 set porcentajeDefectuoso = totalProducto/(totalDefectuoso*100);
 
 if porcentajeDefectuoso < menosDefectuoso then
 set menosDefectuoso = porcentajeDefectuoso;
 set idMenosDefectuoso = v_idProducto;
 end if;
 
 end loop;
 close cur;
 
 set productoMenosDefectuosoHoy = idMenosDefectuoso;
 
 
end
delimiter ;