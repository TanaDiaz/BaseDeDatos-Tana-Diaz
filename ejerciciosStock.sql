
delimiter //
create trigger affaffaaf after insert on pedido_producto for each row
begin
update ingresostock_producto
set cantidad = cantidad - new.cantidad
where producto_codproducto = new.producto_codproducto
limit 1;
end//

delimiter ;