use libreria_ecommerce;

-- Funciones

-- 1) Tiempo promedio (en días) que tarda un usuario en vender sus
-- productos publicados (desde fecha_publicacion hasta la venta).
drop function if exists tiempoPromedioVenta;
delimiter //
create function tiempoPromedioVenta(idVendedor int)
returns decimal(10,2)
not deterministic
reads sql data
begin
declare promedio decimal(10,2);

select avg(datediff(v.fecha_venta, p.fecha_publicacion))
into promedio
from publicaciones p
join ventas v on v.id_publicacion = p.id_publicacion
where p.id_usuario_vendedor = idVendedor
and v.estado = 'Concretada';

return ifnull(promedio, 0);
end//
delimiter ;

-- 2) Comisión del sistema según nivel del vendedor.
-- Normal 8% - Platinum 5% - Gold 3% - nivel inválido -> -1
drop function if exists calcularComision;
delimiter //
create function calcularComision(monto decimal(10,2), nivelVendedor varchar(20))
returns decimal(10,2)
deterministic
no sql
begin
declare comision decimal(10,2);

case nivelVendedor
when 'Normal' then set comision = monto * 0.08;
when 'Platinum' then set comision = monto * 0.05;
when 'Gold' then set comision = monto * 0.03;
else set comision = -1;
end case;

return comision;
end//
delimiter ;

-- 3) Porcentaje de ventas concretadas de un vendedor
-- (ventas / total de publicaciones) * 100. Sin publicaciones -> 0.
drop function if exists porcentajeVentasConcretadas;
delimiter //
create function porcentajeVentasConcretadas(idVendedor int)
returns decimal(5,2)
not deterministic
reads sql data
begin
declare totalPublicaciones int default 0;
declare totalVendidas int default 0;
declare porcentaje decimal(5,2) default 0;

select count(*) into totalPublicaciones
from publicaciones
where id_usuario_vendedor = idVendedor;

if totalPublicaciones = 0 then
return 0;
end if;

select count(*) into totalVendidas
from publicaciones p
join ventas v on v.id_publicacion = p.id_publicacion and v.estado = 'Concretada'
where p.id_usuario_vendedor = idVendedor;

set porcentaje = (totalVendidas / totalPublicaciones) * 100;
return porcentaje;
end//
delimiter ;

-- 4) Mayor precio ofertado hasta el momento en una subasta.
-- No es subasta -> -1 | Sin pujas -> 0
drop function if exists mayorPrecioOfertado;
delimiter //
create function mayorPrecioOfertado(idPublicacion int)
returns decimal(10,2)
not deterministic
reads sql data
begin
declare tipoPub varchar(10);
declare maxOferta decimal(10,2);

select tipo_venta into tipoPub
from publicaciones
where id_publicacion = idPublicacion;

if tipoPub is null or tipoPub <> 'Subasta' then
return -1;
end if;

select max(monto) into maxOferta
from pujas
where id_publicacion = idPublicacion;

return ifnull(maxOferta, 0);
end//
delimiter ;

-- 5) Precio promedio de los productos publicados en una categoría.
drop function if exists precioPromedioCategoria;
delimiter //
create function precioPromedioCategoria(idCategoria int)
returns decimal(10,2)
not deterministic
reads sql data
begin
declare promedio decimal(10,2);

select avg(precio) into promedio
from publicaciones
where id_categoria = idCategoria;

return ifnull(promedio, 0);
end//
delimiter ;

-- 6) Última fecha de compra de un usuario.
drop function if exists ultimaFechaCompra;
delimiter //
create function ultimaFechaCompra(idUsuario int)
returns datetime
not deterministic
reads sql data
begin
declare ultimaFecha datetime;

select max(fecha_venta) into ultimaFecha
from ventas
where id_comprador = idUsuario
and estado = 'Concretada';

return ultimaFecha;
end//
delimiter ;

-- Procedimientos
-- Nota: todos los procedimientos tienen un parámetro de salida
-- p_resultado que indica si la operación se pudo realizar o no.

-- 1) Listar publicaciones que contienen el nombre de un producto,
-- ya sea en el título o en la descripción.
drop procedure if exists buscarPublicacionesPorProducto;
delimiter //
create procedure buscarPublicacionesPorProducto(
in p_nombreBuscado varchar(200),
out p_resultado varchar(255)
)
begin
select pub.id_publicacion, pr.nombre as titulo, pub.precio
from publicaciones pub
join productos pr on pr.id_producto = pub.id_producto
where pr.nombre like concat('%', p_nombreBuscado, '%')
or pr.descripcion like concat('%', p_nombreBuscado, '%');

set p_resultado = 'OK';
end//
delimiter ;

-- 2) Pujar en una subasta.
-- Requiere: publicación de tipo Subasta, no finalizada, y monto
-- mayor al máximo ofertado hasta el momento.
drop procedure if exists realizarPuja;
delimiter //
create procedure realizarPuja(
in p_idPublicacion int,
in p_idUsuario int,
in p_monto decimal(10,2),
out p_resultado varchar(255)
)
begin
declare v_tipoVenta varchar(10);
declare v_estado varchar(15);
declare v_maxOferta decimal(10,2);

declare exit handler for sqlexception
begin
rollback;
set p_resultado = 'no se pudo registrar la puja';
end;

start transaction;

-- Bloqueamos la fila de la publicación (FOR UPDATE) para que dos
-- pujas concurrentes no lean la misma oferta máxima y las dos crean
-- que superan el valor vigente (ver justificación en TRANSACCIONES).
select tipo_venta, estado into v_tipoVenta, v_estado
from publicaciones
where id_publicacion = p_idPublicacion
for update;

if v_tipoVenta is null then
rollback;
set p_resultado = 'la publicación no existe';
elseif v_tipoVenta <> 'Subasta' then
rollback;
set p_resultado = 'la publicación no es una subasta';
elseif v_estado = 'Finalizada' then
rollback;
set p_resultado = 'la publicación ya está finalizada';
else
select max(monto) into v_maxOferta
from pujas
where id_publicacion = p_idPublicacion;

if v_maxOferta is not null and p_monto <= v_maxOferta then
rollback;
set p_resultado = 'el monto debe ser mayor a la oferta actual';
else
insert into pujas (id_publicacion, id_usuario, monto)
values (p_idPublicacion, p_idUsuario, p_monto);
commit;
set p_resultado = 'puja registrada';
end if;
end if;
end//
delimiter ;

-- 3) Pausar una publicación.
-- Solo venta directa, no finalizada, y solo el vendedor dueño.
drop procedure if exists pausarPublicacion;
delimiter //
create procedure pausarPublicacion(
in p_idPublicacion int,
in p_idUsuario int,
out p_resultado varchar(255)
)
begin
declare v_tipoVenta varchar(10);
declare v_estado varchar(15);
declare v_vendedor int;

select tipo_venta, estado, id_usuario_vendedor
into v_tipoVenta, v_estado, v_vendedor
from publicaciones
where id_publicacion = p_idPublicacion;

if v_tipoVenta is null then
set p_resultado = 'la publicación no existe';
elseif v_tipoVenta <> 'Directa' then
set p_resultado = 'solo se pueden pausar publicaciones de venta directa';
elseif v_estado = 'Finalizada' then
set p_resultado = 'la publicación ya está finalizada';
elseif v_vendedor <> p_idUsuario then
set p_resultado = 'solo el vendedor puede pausar la publicación';
else
update publicaciones set estado = 'Pausada' where id_publicacion = p_idPublicacion;
set p_resultado = 'publicación pausada';
end if;
end//
delimiter ;

-- 4) Actualizar el nivel de un usuario según su cantidad de ventas y
-- facturación como vendedor. Devuelve el nuevo nivel.
-- Normal: 1 a 5 ventas.
-- Platinum: 6 a 10 ventas o facturación >= 100.000.
-- Gold: 11+ ventas o facturación >= 1.000.000.
drop procedure if exists actualizarNivelUsuario;
delimiter //
create procedure actualizarNivelUsuario(
in p_idUsuario int,
out p_nuevoNivel varchar(20),
out p_resultado varchar(255)
)
begin
declare v_cantVentas int default 0;
declare v_facturacion decimal(12,2) default 0;

if not exists (select 1 from usuarios where id_usuario = p_idUsuario) then
set p_resultado = 'el usuario no existe';
set p_nuevoNivel = null;
else
select count(*), ifnull(sum(v.monto_final), 0)
into v_cantVentas, v_facturacion
from ventas v
join publicaciones p on p.id_publicacion = v.id_publicacion
where p.id_usuario_vendedor = p_idUsuario
and v.estado = 'Concretada';

-- Un usuario sin ventas todavía no tiene categorización (no es
-- "Normal" desde el registro: Normal arranca en 1 venta).
if v_cantVentas = 0 then
set p_nuevoNivel = null;
elseif v_cantVentas >= 11 or v_facturacion >= 1000000 then
set p_nuevoNivel = 'Gold';
elseif v_cantVentas >= 6 or v_facturacion >= 100000 then
set p_nuevoNivel = 'Platinum';
else
set p_nuevoNivel = 'Normal';
end if;

update usuarios set nivel = p_nuevoNivel where id_usuario = p_idUsuario;
set p_resultado = 'OK: nivel actualizado';
end if;
end//
delimiter ;

-- 5) Calificar a un usuario (comprador o vendedor) tras una venta.
-- Valida rango 0-100, que la venta exista y que el calificador haya
-- participado en la transacción.
drop procedure if exists calificarUsuario;
delimiter //
create procedure calificarUsuario(
in p_idVenta int,
in p_idCalificador int,
in p_idCalificado int,
in p_puntaje decimal(5,2),
in p_comentario varchar(255),
in p_tipoCalificacion varchar(10), -- 'Comprador' o 'Vendedor'
out p_resultado varchar(255)
)
begin
declare v_comprador int;
declare v_vendedor int;

if p_puntaje < 0 or p_puntaje > 100 then
set p_resultado = 'el puntaje debe estar entre 0 y 100';
else
select v.id_comprador, p.id_usuario_vendedor
into v_comprador, v_vendedor
from ventas v
join publicaciones p on p.id_publicacion = v.id_publicacion
where v.id_venta = p_idVenta;

if v_comprador is null then
set p_resultado = 'la venta no existe';
elseif p_idCalificador not in (v_comprador, v_vendedor) then
set p_resultado = 'el usuario no participó de esta transacción';
elseif p_idCalificado not in (v_comprador, v_vendedor) then
set p_resultado = 'el usuario calificado no participó de esta transacción';
elseif p_idCalificador = p_idCalificado then
set p_resultado = 'un usuario no puede calificarse a sí mismo';
else
insert into calificaciones
(id_venta, id_usuario_calificador, id_usuario_calificado, puntaje, comentario, tipo_calificacion)
values
(p_idVenta, p_idCalificador, p_idCalificado, p_puntaje, p_comentario, p_tipoCalificacion);
set p_resultado = 'OK: calificación registrada';
end if;
end if;
end//
delimiter ;

-- 6) Mostrar el usuario ganador de una subasta: usuario, email, nombre
-- del producto, cantidad de oferentes, valor mínimo/inicial y valor
-- ganador.
drop procedure if exists usuarioGanadorSubasta;
delimiter //
create procedure usuarioGanadorSubasta(
in p_idPublicacion int,
out p_resultado varchar(255)
)
begin
declare v_tipoVenta varchar(10);

select tipo_venta into v_tipoVenta
from publicaciones
where id_publicacion = p_idPublicacion;

if v_tipoVenta is null then
set p_resultado = 'la publicación no existe';
elseif v_tipoVenta <> 'Subasta' then
set p_resultado = 'la publicación no es una subasta';
elseif not exists (
select 1 from ventas
where id_publicacion = p_idPublicacion
and estado = 'Concretada'
) then
-- Corrección: antes, si la subasta todavía no tenía ganador,
-- el SELECT devolvía 0 filas mostrando igual p_resultado = 'OK'.
set p_resultado = 'la subasta todavía no tiene ganador';
else
select
u.id_usuario,
u.email,
pr.nombre as nombre_producto,
(select count(distinct id_usuario) from pujas where id_publicacion = p_idPublicacion) as cantidad_oferentes,
pub.precio as valor_inicial,
v.monto_final as valor_ganador
from ventas v
join usuarios u on u.id_usuario = v.id_comprador
join publicaciones pub on pub.id_publicacion = v.id_publicacion
join productos pr on pr.id_producto = pub.id_producto
where v.id_publicacion = p_idPublicacion
and v.estado = 'Concretada';

set p_resultado = 'OK';
end if;
end//
delimiter ;

-- 7) Crear una pregunta sobre una publicación.
-- Valida que la publicación exista y esté activa, que el contenido
-- no sea nulo y que el usuario no sea el dueño de la publicación.
drop procedure if exists crearPregunta;
delimiter //
create procedure crearPregunta(
in p_idPublicacion int,
in p_idUsuario int,
in p_contenido text,
out p_resultado varchar(255)
)
begin
declare v_estado varchar(15);
declare v_vendedor int;

select estado, id_usuario_vendedor into v_estado, v_vendedor
from publicaciones
where id_publicacion = p_idPublicacion;

if v_estado is null then
set p_resultado = 'la publicación no existe';
elseif v_estado <> 'Activa' then
set p_resultado = 'la publicación no está activa';
elseif p_contenido is null or trim(p_contenido) = '' then
set p_resultado = 'el contenido de la pregunta no puede estar vacío';
elseif p_idUsuario = v_vendedor then
set p_resultado = 'el vendedor no puede preguntar en su propia publicación';
else
insert into preguntas (id_publicacion, id_usuario, contenido)
values (p_idPublicacion, p_idUsuario, p_contenido);
set p_resultado = 'OK: pregunta creada';
end if;
end//
delimiter ;

-- 8) Estadísticas de un vendedor: publicaciones activas, finalizadas,
-- ventas totales, facturación total, precio promedio de los
-- productos que vende, preguntas recibidas y tiempo promedio de venta.
drop procedure if exists estadisticasVendedor;
delimiter //
create procedure estadisticasVendedor(
in p_idVendedor int,
out p_resultado varchar(255)
)
begin
if not exists (select 1 from usuarios where id_usuario = p_idVendedor) then
set p_resultado = 'el usuario no existe';
else
select
(select count(*) from publicaciones where id_usuario_vendedor = p_idVendedor and estado='Activa') as publicaciones_activas,
(select count(*) from publicaciones where id_usuario_vendedor = p_idVendedor and estado='Finalizada') as publicaciones_finalizadas,
(select count(*) from ventas v join publicaciones p on p.id_publicacion = v.id_publicacion
where p.id_usuario_vendedor = p_idVendedor and v.estado = 'Concretada') as ventas_totales,
(select ifnull(sum(v.monto_final),0) from ventas v join publicaciones p on p.id_publicacion = v.id_publicacion
where p.id_usuario_vendedor = p_idVendedor and v.estado = 'Concretada') as facturacion_total,
(select ifnull(avg(precio),0) from publicaciones where id_usuario_vendedor = p_idVendedor) as precio_promedio,
(select count(*) from preguntas pr join publicaciones p on p.id_publicacion = pr.id_publicacion
where p.id_usuario_vendedor = p_idVendedor) as preguntas_recibidas,
tiempoPromedioVenta(p_idVendedor) as tiempo_promedio_venta;

set p_resultado = 'OK';
end if;
end//
delimiter ;

-- 9) Top 10 mejores vendedores del mes (mayor cantidad de ventas) en un
-- rango de fechas dado.
drop procedure if exists topVendedoresDelMes;
delimiter //
create procedure topVendedoresDelMes(
in p_fechaInicio date,
in p_fechaFin date,
out p_resultado varchar(255)
)
begin
if p_fechaInicio is null or p_fechaFin is null or p_fechaInicio > p_fechaFin then
set p_resultado = 'rango de fechas inválido';
else
select
u.id_usuario,
u.nombre,
u.apellido,
count(v.id_venta) as cantidad_ventas,
sum(v.monto_final) as facturacion
from ventas v
join publicaciones p on p.id_publicacion = v.id_publicacion
join usuarios u on u.id_usuario = p.id_usuario_vendedor
where v.estado = 'Concretada'
and date(v.fecha_venta) between p_fechaInicio and p_fechaFin
group by u.id_usuario, u.nombre, u.apellido
order by cantidad_ventas desc
limit 10;

set p_resultado = 'OK';
end if;
end//
delimiter ;

-- Vistas

-- 1) Preguntas de publicaciones activas que aún no tienen respuesta.
-- Se incluye id de la pregunta, descripción, publicación, nombre del
-- producto y nombre del usuario que realizó la pregunta.
drop view if exists vista_preguntas_sin_responder;
create view vista_preguntas_sin_responder as
select
pr.id_pregunta,
pr.contenido as descripcion,
pr.id_publicacion,
prod.nombre as nombre_producto,
concat(u.nombre, ' ', u.apellido) as nombre_usuario_pregunta
from preguntas pr
join publicaciones pub on pub.id_publicacion = pr.id_publicacion
join productos prod on prod.id_producto = pub.id_producto
join usuarios u on u.id_usuario = pr.id_usuario
where pub.estado = 'Activa'
and not exists (select 1 from respuestas r where r.id_pregunta = pr.id_pregunta);

-- 2) Top 10 categorías más presentes en publicaciones de esta semana.
drop view if exists vista_top10_categorias_semana;
create view vista_top10_categorias_semana as
select
c.id_categoria,
c.nombre as nombre_categoria,
count(*) as cantidad_publicaciones
from publicaciones p
join categorias c on c.id_categoria = p.id_categoria
where yearweek(p.fecha_publicacion, 1) = yearweek(curdate(), 1)
group by c.id_categoria, c.nombre
order by cantidad_publicaciones desc
limit 10;

-- 3) Publicaciones en tendencia hoy: las que tienen mayor cantidad de
-- preguntas HECHAS HOY (entre las publicaciones activas).
-- Corrección: la versión original contaba TODAS las preguntas
-- históricas de la publicación, no solo las de hoy, por lo que nunca
-- reflejaba la tendencia "del día".
drop view if exists vista_publicaciones_tendencia;
create view vista_publicaciones_tendencia as
select
p.id_publicacion,
prod.nombre as nombre_producto,
p.estado,
count(pr.id_pregunta) as cantidad_preguntas
from publicaciones p
join productos prod on prod.id_producto = p.id_producto
join preguntas pr on pr.id_publicacion = p.id_publicacion
where p.estado = 'Activa'
and date(pr.fecha_creacion) = curdate()
group by p.id_publicacion, prod.nombre, p.estado
having cantidad_preguntas > 0
order by cantidad_preguntas desc
limit 10;

-- 4) Vendedor con mayor reputación por categoría.
drop view if exists vista_mejor_reputacion_por_categoria;
create view vista_mejor_reputacion_por_categoria as
select
c.nombre as nombre_categoria,
(select concat(u2.nombre, ' ', u2.apellido)
from usuarios u2
join publicaciones p2 on p2.id_usuario_vendedor = u2.id_usuario
where p2.id_categoria = c.id_categoria
order by u2.reputacion desc, u2.id_usuario asc
limit 1) as nombre_vendedor
from categorias c
where exists (select 1 from publicaciones p3 where p3.id_categoria = c.id_categoria);

-- Triggers

-- 1) Antes de eliminar una pregunta, eliminar todas las respuestas
-- asociadas.
-- (En este modelo respuestas.id_pregunta tiene ON DELETE CASCADE,
-- por lo que el borrado en cascada ya ocurre a nivel de FK; se deja
-- igualmente el trigger, tal como lo pide la consigna, de forma
-- explícita e idempotente.)
drop trigger if exists trg_before_delete_pregunta;
delimiter //
create trigger trg_before_delete_pregunta
before delete on preguntas
for each row
begin
delete from respuestas where id_pregunta = old.id_pregunta;
end//
delimiter ;

-- 2) Después de realizarse una venta, actualizar el nivel del usuario
-- vendedor.
drop trigger if exists trg_after_insert_venta;
delimiter //
create trigger trg_after_insert_venta
after insert on ventas
for each row
begin
declare v_idVendedor int;
declare v_cantVentas int default 0;
declare v_facturacion decimal(12,2) default 0;
declare v_nuevoNivel varchar(20);

if new.estado = 'Concretada' then
select id_usuario_vendedor into v_idVendedor
from publicaciones where id_publicacion = new.id_publicacion;

select count(*), ifnull(sum(v.monto_final), 0)
into v_cantVentas, v_facturacion
from ventas v
join publicaciones p on p.id_publicacion = v.id_publicacion
where p.id_usuario_vendedor = v_idVendedor
and v.estado = 'Concretada';

if v_cantVentas >= 11 or v_facturacion >= 1000000 then
set v_nuevoNivel = 'Gold';
elseif v_cantVentas >= 6 or v_facturacion >= 100000 then
set v_nuevoNivel = 'Platinum';
else
set v_nuevoNivel = 'Normal';
end if;

update usuarios set nivel = v_nuevoNivel where id_usuario = v_idVendedor;

-- La publicación vendida se marca como finalizada
update publicaciones
set estado = 'Finalizada', fecha_finalizacion = new.fecha_venta
where id_publicacion = new.id_publicacion;
end if;
end//
delimiter ;

-- 3) Después de calificar a un usuario, actualizar su reputación
-- (promedio de todos los puntajes recibidos).
drop trigger if exists trg_after_insert_calificacion;
delimiter //
create trigger trg_after_insert_calificacion
after insert on calificaciones
for each row
begin
declare v_promedio decimal(5,2);

select avg(puntaje) into v_promedio
from calificaciones
where id_usuario_calificado = new.id_usuario_calificado;

update usuarios
set reputacion = v_promedio
where id_usuario = new.id_usuario_calificado;
end//
delimiter ;

-- 4) Al realizarse una puja, validar que la publicación no esté
-- finalizada, que el usuario no sea el vendedor y que el monto
-- pujado sea el mayor hasta el momento.
drop trigger if exists trg_before_insert_puja;
delimiter //
create trigger trg_before_insert_puja
before insert on pujas
for each row
begin
declare v_estado varchar(15);
declare v_vendedor int;
declare v_maxOferta decimal(10,2);

select estado, id_usuario_vendedor into v_estado, v_vendedor
from publicaciones
where id_publicacion = new.id_publicacion;

if v_estado = 'Finalizada' then
signal sqlstate '45000'
set message_text = 'No se puede pujar: la publicación está finalizada';
end if;

if new.id_usuario = v_vendedor then
signal sqlstate '45000'
set message_text = 'El vendedor no puede pujar en su propia publicación';
end if;

select max(monto) into v_maxOferta
from pujas
where id_publicacion = new.id_publicacion;

if v_maxOferta is not null and new.monto <= v_maxOferta then
signal sqlstate '45000'
set message_text = 'El monto pujado debe ser mayor a la oferta actual';
end if;
end//
delimiter ;

-- Eventos

set global event_scheduler = on;

-- 1) Una vez por semana, eliminar publicaciones pausadas creadas hace
-- más de 90 días.
drop event if exists evt_borrar_publicaciones_pausadas;
delimiter //
create event evt_borrar_publicaciones_pausadas
on schedule every 1 week starts current_timestamp
do
begin
delete from publicaciones
where estado = 'Pausada'
and fecha_publicacion <= now() - interval 90 day;
end//
delimiter ;

-- 2) Diariamente, marcar como "Observada" las publicaciones activas de
-- tipo venta directa que no tienen configurado un medio de pago.
drop event if exists evt_marcar_publicaciones_observadas;
delimiter //
create event evt_marcar_publicaciones_observadas
on schedule every 1 day starts current_timestamp
do
begin
update publicaciones p
set p.estado = 'Observada'
where p.tipo_venta = 'Directa'
and p.estado = 'Activa'
and not exists (
select 1 from publicacion_medio_pago pmp
where pmp.id_publicacion = p.id_publicacion
);
end//
delimiter ;

-- 3) Todos los días a las 10:00, notificar a los vendedores sobre las
-- preguntas sin responder de sus publicaciones activas.
-- Mensaje: "La publicación sobre {titulo} tiene {cantidad} sin responder"
drop event if exists evt_notificar_preguntas_sin_responder;
delimiter //
create event evt_notificar_preguntas_sin_responder
on schedule every 1 day starts timestamp(curdate(), '10:00:00')
do
begin
insert into notificaciones (id_usuario, mensaje)
select
pub.id_usuario_vendedor,
concat('La publicación sobre ', prod.nombre, ' tiene ', count(*), ' sin responder')
from preguntas pr
join publicaciones pub on pub.id_publicacion = pr.id_publicacion
join productos prod on prod.id_producto = pub.id_producto
where pub.estado = 'Activa'
and not exists (select 1 from respuestas r where r.id_pregunta = pr.id_pregunta)
group by pub.id_usuario_vendedor, pub.id_publicacion, prod.nombre;
end//
delimiter ;

-- 4) Todos los días a las 00:00, generar estadísticas sobre vendedores,
-- compradores y productos del día anterior.
drop event if exists evt_generar_estadisticas_diarias;
delimiter //
create event evt_generar_estadisticas_diarias
on schedule every 1 day starts timestamp(curdate(), '00:00:00')
do
begin
insert into estadisticas_diarias
(fecha, cant_ventas, facturacion_total, cant_usuarios_nuevos, cant_productos_nuevos)
select
curdate() - interval 1 day,
(select count(*) from ventas where date(fecha_venta) = curdate() - interval 1 day and estado = 'Concretada'),
(select ifnull(sum(monto_final),0) from ventas where date(fecha_venta) = curdate() - interval 1 day and estado = 'Concretada'),
(select count(*) from usuarios where date(fecha_registro) = curdate() - interval 1 day),
(select count(*) from productos where date(fecha_creacion) = curdate() - interval 1 day);
end//
delimiter ;

-- Índices

-- 1) Índices para acelerar la búsqueda por nombre de producto.
-- IMPORTANTE: buscarPublicacionesPorProducto filtra con
-- LIKE CONCAT('%', término, '%'), es decir con comodín AL INICIO.
-- Un índice B-Tree normal (como idx_producto_nombre) NO puede ser
-- usado por el optimizador en ese caso -- solo acelera patrones del
-- tipo 'texto%' (comodín al final). Para que la búsqueda por nombre
-- y descripción esté realmente optimizada se agrega un índice
-- FULLTEXT sobre ambas columnas.
create index idx_producto_nombre on productos(nombre);
create index idx_producto_autor on productos(autor);
create fulltext index ftx_producto_nombre_descripcion on productos(nombre, descripcion);

-- 2) Índice único para que no se repitan direcciones de email en la
-- tabla de usuarios.
create unique index uidx_usuario_email on usuarios(email);

-- 3) Índices para optimizar las consultas frecuentes sobre publicaciones
-- activas, pausadas o finalizadas. Se agrega también un índice
-- compuesto por vendedor+estado, muy usado en estadisticasVendedor
-- y en los listados de publicaciones de un vendedor.
create index idx_publicacion_estado on publicaciones(estado);
create index idx_publicacion_vendedor_estado on publicaciones(id_usuario_vendedor, estado);

-- Transacciones

-- 1) ¿Qué transacción se debería crear para la acción de COMPRAR una
-- publicación? ¿Por qué?
-- Comprar una publicación no es una única escritura: implica, como
-- mínimo, (a) insertar el registro en "ventas", (b) actualizar el
-- estado de la publicación a "Finalizada" y (c) recalcular el nivel
-- del vendedor. Si el sistema fallara entre el paso (a) y el (b),
-- podríamos terminar con una venta registrada pero la publicación
-- seguiría figurando como "Activa" (y otro comprador podría intentar
-- comprarla de nuevo), o viceversa. Envolver toda la operación en una
-- transacción garantiza ATOMICIDAD: o se aplican todos los cambios, o
-- no se aplica ninguno, evitando estados intermedios inconsistentes.
-- Además, como puede haber más de un comprador intentando cerrar la
-- misma publicación al mismo tiempo, conviene usar un SELECT ... FOR
-- UPDATE sobre la publicación para bloquearla mientras dura la
-- transacción (evita condiciones de carrera / doble venta).

drop procedure if exists comprarPublicacion;
delimiter //
create procedure comprarPublicacion(
in p_idPublicacion int,
in p_idComprador int,
in p_idMedioPago int,
in p_idMedioEnvio int,
out p_resultado varchar(255)
)
begin
declare v_estado varchar(15);
declare v_precio decimal(10,2);
declare v_vendedor int;

declare exit handler for sqlexception
begin
rollback;
set p_resultado = 'no se pudo concretar la compra';
end;

start transaction;

-- Bloqueamos la fila para evitar que dos compradores concreten
-- la misma publicación en simultáneo (doble venta).
select estado, precio, id_usuario_vendedor
into v_estado, v_precio, v_vendedor
from publicaciones
where id_publicacion = p_idPublicacion
for update;

if v_estado is null then
rollback;
set p_resultado = 'la publicación no existe';
elseif v_estado <> 'Activa' then
rollback;
set p_resultado = 'la publicación no está activa';
elseif v_vendedor = p_idComprador then
rollback;
set p_resultado = 'el vendedor no puede comprar su propia publicación';
else
insert into ventas (id_publicacion, id_comprador, id_medio_pago, id_medio_envio, monto_final, estado)
values (p_idPublicacion, p_idComprador, p_idMedioPago, p_idMedioEnvio, v_precio, 'Concretada');

-- El trigger trg_after_insert_venta se encarga de finalizar la
-- publicación y de actualizar el nivel del vendedor; ambas
-- acciones quedan dentro de la misma transacción.

commit;
set p_resultado = 'OK: compra concretada';
end if;
end//
delimiter ;

-- 2) ¿Qué transacción se debería crear para la acción de PUJAR en una
-- subasta? ¿Por qué?
-- Pujar requiere primero LEER cuál es la mayor oferta actual y luego
-- ESCRIBIR una nueva puja únicamente si supera ese valor. Entre la
-- lectura y la escritura puede colarse otra transacción que inserte
-- una puja más alta (problema de "actualización perdida" / condición
-- de carrera), lo que permitiría insertar una puja que en realidad ya
-- no es la mayor. Por eso esta operación debe ejecutarse dentro de una
-- transacción, bloqueando la fila de la publicación (FOR UPDATE)
-- mientras se valida el monto e inserta la puja, para que las pujas
-- concurrentes se serialicen. El procedimiento "realizarPuja" hace
-- exactamente eso; el trigger trg_before_insert_puja agrega una
-- segunda capa de validación a nivel de tabla (útil si alguien
-- insertara en "pujas" sin pasar por el procedimiento).

-- 3) Otro ejemplo de transacción necesaria en este negocio.
-- Calificar a un usuario al finalizar una operación: insertar la fila
-- en "calificaciones" y, a través del trigger, recalcular la
-- "reputacion" del usuario calificado (promedio de puntajes) deben
-- ocurrir de forma atómica. Si el insert se confirma pero la
-- actualización de reputación falla, el usuario quedaría con una
-- reputación desactualizada/inconsistente respecto a sus
-- calificaciones reales. Otro caso típico sería cancelar una venta:
-- habría que revertir el estado de la publicación a "Activa", marcar
-- la venta como "Cancelada" y, potencialmente, recalcular el nivel del
-- vendedor; todo eso también debería viajar dentro de una única
-- transacción.

-- Roles y acceso
-- Extra: no figura en el formato de entrega pedido, pero está en el
-- enunciado, así que se incluye como complemento.

-- 1) Rol de auditor: puede consultar las vistas creadas.
create role if not exists 'rol_auditor';
grant select on libreria_ecommerce.vista_preguntas_sin_responder to 'rol_auditor';
grant select on libreria_ecommerce.vista_top10_categorias_semana to 'rol_auditor';
grant select on libreria_ecommerce.vista_publicaciones_tendencia to 'rol_auditor';
grant select on libreria_ecommerce.vista_mejor_reputacion_por_categoria to 'rol_auditor';

-- 2) Rol de desarrollador: select sobre toda la base y permiso para
-- crear rutinas (funciones, procedimientos, triggers).
create role if not exists 'rol_desarrollador';
grant select on libreria_ecommerce.* to 'rol_desarrollador';
grant create routine, alter routine, execute, trigger on libreria_ecommerce.* to 'rol_desarrollador';

-- 3) Rol de admin: acceso total a la base de datos.
create role if not exists 'rol_admin';
grant all privileges on libreria_ecommerce.* to 'rol_admin';

-- Ejemplo de asignación de roles a usuarios de MySQL (no confundir con
-- los usuarios de la aplicación, que viven en la tabla "usuarios"):
-- create user 'auditor1'@'localhost' identified by 'ClaveSegura123';
-- grant 'rol_auditor' to 'auditor1'@'localhost';
-- set default role 'rol_auditor' to 'auditor1'@'localhost';