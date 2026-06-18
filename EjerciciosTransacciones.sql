
delimiter $$

create procedure realizar_compra(
in p_cliente int,
in p_producto varchar(15),
in p_cantidad int,
in p_fecha_envio date
)
begin
declare v_stock int;
declare v_pedido int;
declare v_precio decimal(10,2);

start transaction;

select quantityinstock, buyprice
into v_stock, v_precio
from products
where productcode = p_producto
for update;

if v_stock < p_cantidad then
rollback;
signal sqlstate '45000'
set message_text = 'error, stock insuficiente';
else

insert into orders(
orderdate,
requireddate,
status,
customernumber
)
values(
curdate(),
p_fecha_envio,
'in process',
p_cliente
);

set v_pedido = last_insert_id();

insert into orderdetails(
ordernumber,
productcode,
quantityordered,
priceeach,
orderlinenumber
)
values(
v_pedido,
p_producto,
p_cantidad,
v_precio,
1
);

update products
set quantityinstock = quantityinstock - p_cantidad
where productcode = p_producto;

commit;
end if;
end$$

delimiter ;


-- 2

delimiter $$

create procedure registrar_pago(
in p_cliente int,
in p_cheque varchar(50),
in p_monto decimal(10,2)
)
begin
declare v_aprobado boolean;

start transaction;

set v_aprobado = simular_pago_tarjeta(p_cheque);

if v_aprobado = false then
rollback;
else

insert into payments(
customernumber,
checknumber,
paymentdate,
amount
)
values(
p_cliente,
p_cheque,
curdate(),
p_monto
);

if p_monto > 800000 then
update customers
set creditlimit = 1500000
where customernumber = p_cliente;
end if;

commit;
end if;
end$$

delimiter ;

-- 3 canc pedido devolver stock

delimiter $$

create procedure cancelar_pedido(
in p_pedido int
)
begin
declare v_estado varchar(20);
declare fin int default 0;

declare v_producto varchar(15);
declare v_cantidad int;

declare cur_productos cursor for
select productcode, quantityordered
from orderdetails
where ordernumber = p_pedido;

declare continue handler for not found set fin = 1;

start transaction;

select status
into v_estado
from orders
where ordernumber = p_pedido
for update;

if v_estado = 'shipped' then
rollback;
signal sqlstate '45000'
set message_text =
'error: no se puede cancelar un pedido que ya fue enviado';
else

open cur_productos;

bucle: loop

fetch cur_productos
into v_producto, v_cantidad;

if fin = 1 then
leave bucle;
end if;

update products
set quantityinstock = quantityinstock + v_cantidad
where productcode = v_producto;

end loop;

close cur_productos;

update orders
set status = 'cancelled'
where ordernumber = p_pedido;

commit;
end if;
end$$

delimiter ;

--  4

delimiter $$

create procedure cambiar_vendedor(
in p_vendedor_viejo int,
in p_vendedor_nuevo int
)
begin
declare v_oficina_vieja varchar(10);
declare v_oficina_nueva varchar(10);

start transaction;

select officecode
into v_oficina_vieja
from employees
where employeenumber = p_vendedor_viejo;

select officecode
into v_oficina_nueva
from employees
where employeenumber = p_vendedor_nuevo;

if v_oficina_nueva is null
or v_oficina_vieja <> v_oficina_nueva then

rollback;

signal sqlstate '45000'
set message_text =
'error: vendedor inapto para esta zona';

else

update customers
set salesrepemployeenumber = p_vendedor_nuevo
where salesrepemployeenumber = p_vendedor_viejo;

commit;

end if;
end$$

delimiter ;