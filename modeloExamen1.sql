delimiter //
create function CompraPaga(compraId) returns boolean
begin

	declare estadoPago boolean default false;
	declare pagado float;
    declare aPagar float;
    
	select SUM(p.monto) into pagado from pago p
	join compra c on c.id = p.compra_id
    where compraId = compra_id;

	select precio into aPagar from compra where id = compra_id;
	if pagado >= aPagar then set estadoPago = true;

	return estadoPago;

end //
delimiter ;




delimiter //
create function comisionEmpleado(empleadoId) returns float
begin
	declare comisionFinal float;
	declare totalVendido float;
	declare antiguedad int;

	select sum(c.precio) into totalVendido from compra c
	join empleado e on e.id = c.empleado_id
	where c.empleado_id = empleadoId;
	
    select fechaIngreso into antiguedad from empleado
    where empleadoId = id;
    
    if fechaIngreso.after(5y) then comisionFinal = totalVendido;
    
end //
delimiter ;