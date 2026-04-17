sores:
9. Crear un SP que utilice un cursor para recorrer la tabla de offices y que genere una lista con
las ciudades en las cuales hay oficinas. La lista tendrá que devolverse en un parámetro de
salida VARCHAR(4000) que contenga todas las ciudades separadas por coma.
getCiudadesOffices()


delimiter //
create procedure getCiudadesOffices(out ciudades varchar(4000))
begin

declare done int default false;
declare ciudad varchar(50);
declare lista varchar(4000) default '';

declare curs cursor for
select city from offices;
declare continue handler for not found set done = true;

open cur;

loop_ciudades: loop
fetch cur into ciudad;
if done then
leave loop_ciudades;
end if;

set lista = concat(lista, ', ', ciudad);
end loop;

close cur;
set ciudades = lista;

end //
delimiter ;


0. Agregar una tabla llamada CancelledOrders con el mismo diseño que la tabla de Orders.
Crear un SP que recorra la tabla de orders y que cuente la cantidad de órdenes en estado
cancelled. El procedimiento debe insertar una fila en la tabla CancelledOrders por cada
orden cancelada y tiene que devolver la cantidad de órdenes canceladas.
insertCancelledOrders()

create table if not exists CancelledOrders (
    orderNumber int not null,
    orderDate date not null,
    requiredDate date not null,
    shippedDate date default null,
    status varchar(15) not null,
    comments text,
    customerNumber int not null,
    primary key (orderNumber)
);

delimiter //
create procedure insertCancelledOrders(out cantidad int)
begin

declare done int default false;
declare v_orderNumber int;
declare v_orderDate date;
declare v_requiredDate date;
declare v_shippedDate date;
declare v_status varchar(15);
declare v_comments text;
declare v_customerNumber int;
declare contador int default 0;

declare cur cursor for
select orderNumber, orderDate, requiredDate, shippedDate,
status, comments, customerNumber
from orders
where status = 'Cancelled';
declare continue handler for not found set done = true;

open cur;

loop_orders: loop
fetch cur into v_orderNumber, v_orderDate, v_requiredDate,
v_shippedDate, v_status, v_comments, v_customerNumber;
if done then
leave loop_orders;
end if;

insert ignore into CancelledOrders
(orderNumber, orderDate, requiredDate, shippedDate,
status, comments, customerNumber)
values
(v_orderNumber, v_orderDate, v_requiredDate, v_shippedDate,
v_status, v_comments, v_customerNumber);

set contador = contador + 1;
end loop;

close cur;
set cantidad = contador;

end //
delimiter ;

11. Realizar un SP que reciba el customerNumber y para todas las órdenes de ese
customerNumber, si el campo comments esta vacío que lo complete con el siguiente
comentario: “El total de la orden es … “ Y el total de la orden tendrá que calcularlo el
procedimiento sumando todos los productos incluidos en la orden de la tabla OrderDetails.
alterCommentOrder()


delimiter //
create procedure alterCommentOrder(in p_customerNumber int)
begin

declare done int default false;
declare v_orderNumber int;
declare v_comments text;
declare v_total decimal(10,2);

declare cur cursor for
select orderNumber, comments from orders
where customerNumber = p_customerNumber;
declare continue handler for not found set done = true;

open cur;

loop_orders: loop
fetch cur into v_orderNumber, v_comments;
if done then
leave loop_orders;
end if;

if v_comments is null or trim(v_comments) = '' then
select sum(quantityOrdered * priceEach)
into v_total
from orderdetails
where orderNumber = v_orderNumber;

update orders
set comments = concat('El total de la orden es ', v_total)
where orderNumber = v_orderNumber;
end if;
end loop;

close cur;

end //
delimiter ;


