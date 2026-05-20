
delimiter //
create trigger affaffaaf after insert on pedido_producto for each row
begin
update ingresostock_producto
set cantidad = cantidad - new.cantidad
where producto_codproducto = new.producto_codproducto
limit 1;
end//

delimiter ;





2)) Crear un trigger que antes de borrar en la tabla IngresoStock borre todas las filas de la tabla
IngresoStock_Producto.

delimiter //
create trigger borrarFilasStock before delete on IngresoStock for each row
begin
delete from IngresoStock_Producto;
end//
delimiter ;



3) Imaginando que agregamos una columna categoría en la tabla de clientes, hacer un trigger que, cada vez
que se agrega un pedido, se calcule el monto total gastado por ese cliente en los últimos dos años y
actualice la categoría del cliente. Las categorías son “bronce” hasta $50.000 inclusive, “ plata”de $50.000 a
$100.000 inclusive y “oro” más de $100.000.


delimiter //
create trigger CalculoCategoria before insert on Pedidos for each row
begin
declare estado varchar(500);
declare monto int;
select montoGastado into monto from Pedidosg

end//
delimiter ;











