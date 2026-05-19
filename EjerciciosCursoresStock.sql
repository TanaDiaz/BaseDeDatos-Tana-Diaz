1. Crear un Stored Procedure que actualice el stock de los productos teniendo en cuenta los
ingresos de esta semana.

delimiter //
create procedure actualizarStock()
begin

declare hayFilas boolean default 1;
declare v_idProducto int;
declare IngresosSemana int;
declare stockPrevio int;
declare stockActualizado int;

declare cur cursor for
select codProducto, stock from Producto;

declare continue handler for not found set hayFilas = 0;

open cur;
loop_stock: loop

fetch cur into v_codProducto, stockPrevio;

if hayFilas = 0 then
leave loop_stock;
end if;

select sum(c.cantidad) into IngresosSemana from ingresoStock is
join ingresostock_producto isp on is.idIngreso = isp.IngresoStock_IdIngreso
join producto p on isp.Producto_codProducto = p.codProducto
where is.fecha >= currentdate() - interval 1 week and p.codProducto = v_idProducto;

set stockActualizado = stockPrevio + IngresosSemana;

update producto set stock = stockActualizado
where codProducto = v_codProducto;


end loop;
close cur;
end
delimiter ;

