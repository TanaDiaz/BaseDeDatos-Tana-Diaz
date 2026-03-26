use classicmodels;

Create view notPaymentClient as select c.customerNumber
from customers c
RIGHT JOIN payments p ON p.customerNumber = c.customerNumber 

			
Crear una vista que liste el nombre, el teléfono y la dirección de los clientes que hicieron
una compra hace más de 2 años y de más de $30000.

create view listarCosillas as select c.nombre, c.telefono, c.direccion from clientes c
join compras co on c.id = co.c_id 
where fecha_compra iadjsadjs AND pago > 30000;


Crear una vista que muestre para todas las órdenes, los códigos de producto que la
componen, indicando del producto: código, nombre, descripción, cantidad ordenada,
precio unitario y el precio total por producto

delimiter //
create function ordenesSegunEstado (fechaInicio date, fechaFin date, estado text) returns int deterministic
begin
declare cantOrdenes int default 0;
select count(*) into cantOrdenes from orders where status = estado and orderDate between 
fechaInicio and fechaFin;
return cantOrdenes;
end//
delimiter;
select ordenesSegunEstado("2023-10-10", current_date(), "Cancelled");


# 3) Crear una función que reciba un número de cliente y devuelva la ciudad a la que
# corresponde el empleado que lo atiende.
delimiter //
create function bottomCliente (ClienteId int) returns varchar deterministic
begin
return select c.id FROM Cliente cl 
join empleado e on cl.EmpleadoId = e.id
join ciudad c  on e.CiudadId = c.id
where cl.ClienteId = ClienteId;
end
delimiter;

 
select bottomCliente(67576);


# PROCEDURES:

Crear un SP que liste todos los productos que tengan un precio de compra mayor al precio
promedio y que devuelva la cantidad de productos que cumplan con esa condición.

delimiter //
create procedure ListaP(out cantidad int)
begin
	select * from products p where p.buyPrice > (select AVG(p.buyPrice) from products p);
	select count(*) into cantidad from products p where p.buyPrice > (select AVG(p.buyPrice) from products p);
	
end// 
delimiter ;


drop procedure ListaP;
call ListaP(@cant);

select @cant;


Crear un SP que reciba un orderNumber y la borre. Previamente debe eliminar todos los
ítems de la tabla orderDetails asociados a él. Tiene que devolver 0 si no encontró filas para
ese orderNumber, o la cantidad ítems borrados si encontró el orderNumber.

delimiter //
create procedure DeleteN (out cantidad int, in orderN int)
begin 
	
	select count(*) into cantidad from orderDetails 
	where orderNumber =  orderN;
	
	IF cantidad = 0 then
	SET cantidad = 0;
	
	ELSE
	delete from orderDetails 
	where orderNumber =  orderN; 
	END IF;
	
end
delimiter ;

call DeleteN(@cant, 5);
select @cant;










