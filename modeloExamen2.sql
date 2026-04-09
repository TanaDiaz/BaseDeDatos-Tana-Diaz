3- Crear una función que reciba el modelo de un auto y un mes, y devuelva la cantidad de autos
de ese modelo vendidos en ese mes.

delimiter //
create function cantAutosVendidos(ModeloId, mes) returns int
begin
	declare cantAutos int;
    
    select count(m.id) into cantAutos from modelos m
    join auto a on a.modelo_id = m.id
    join compra c on c.auto_patente = a.id
    where m.id = ModeloId AND MONTH(c.fecha) = mes;
    
    return cantAutos;
end
delimiter ;







Crear una vista que muestre el resumen de todas las ventas, incluyendo dni y mail del cliente,
fecha de compra, patente, marca y color del auto, y si está completamente paga o no. Utilizar la
función del punto 1).


create view resumenVentas as select cl.dni, cl.mail, c.fecha, m.marca, a.color, pagado(c.id) as estado_pago from cliente cl
join compra c on c.cliente_id = cl.id
join auto a on a.id = c.auto_id
join modelo m on m.id = a.modelo_id;




Crear una vista que muestre un resumen de las ventas por mes. El resumen debe listar el nombre
del modelo de auto, la cantidad de ventas, la ganancia en pesos y el día en el que se vendieron
más autos de ese modelo. Utilizar la función del punto 3).


delimiter //
create function masVentasModeloxDia(modelo_id int, p_mes int) returns int
begin
	declare diaVentas int;
	
	select DAY(c.fecha) into diaVentas from compra c
    join auto a on a.id = c.auto_id
	join modelo m on m.id = a.modelo_id
    where m.id = modelo_id AND MONTH(c.fecha) = p_mes
    group by DAY(c.fecha)
    order by count(*) desc
    limit 1;
    return diaVentas;
end
delimiter ;


create view resumenVentasxMes as select m.modelo, count(c.id), sum(c.monto), cantAutosVendidos(m.id, MONTH(c.fecha)), masVentasModeloxDia(m.id, MONTH(c.fecha))
from compra c
join auto a on a.id = c.auto_id
join modelo m on m.id = a.modelo_id
group by m.id, MONTH(c.fecha);







