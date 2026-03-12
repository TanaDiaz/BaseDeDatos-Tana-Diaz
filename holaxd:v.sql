create DATABASE IF NOT EXISTS TORNEO;
USE papu;

CREATE TABLE JUGADOR(
id int auto_increment primary key,
mail varchar(30) unique not null,
Nombre varchar(20) not null,
Apellido varchar(15) not null,
pais varchar(20)not null,
fecha_de_nacimiento date not null
);

create table equipo(
id int auto_increment primary key,
nombre varchar(20) unique not null,
capitan int,
foreign key (capitan) references JUGADOR (id)
);

create table videojuegos(
id int auto_increment primary key,
nombre varchar(20) unique not null,
genero varchar(20) not null,
edad int check (edad > 18)
);

create table torneos(
id int auto_increment primary key,
nombre varchar(20) unique not null,
fecha_de_inicio date not null,
fecha_de_finalizacion date not null,
premio int not null,
videojuegos_id int,
foreign key (videojuegos_id) references videojuegos(id)
);

create table torneos_has_equipo(
id_torneos int, 
id_equipo int,
posicion_final int,
key (id_torneos, id_equipo),
foreign key (id_torneos) references torneos(id),
foreign key (id_equipo) references equipo(id)
);


create table jugador_has_equipo(
id_jugador int, 
id_equipo int,
key (id_jugador, id_equipo),
foreign key (id_jugador) references jugador(id),
foreign key (id_equipo) references equipo(id)
);



select Nombre, Apellido from JUGADOR
where pais = 'Argentina'
order by Apellido ASC;


select nombre from videojuegos 
where edad >= 16;

select e.nombre, j.nombre from equipo e
join JUGADOR j on e.capitan = j.id;

select e.nombre, t.nombre, te.fecha_inscripcion, t.posicion_final from torneo t 
join torneos_has_equipo te on t.id = te.id_torneos 
join equipos e on te.id_equipo = e.id;

select pais, count(*) from jugadores 
group by pais;

select count(*) as c_torneos, v.nombre from torneo t
join videojuego v on t.videojuegos_id = v.id
group by v.id
order by c_torneos DESC
limit 1;

update torneo set premio = premio*2
where id = (select premio from torneo group by idEquipo having count(*) < 3);



update videojuegos set "[Popular]" + nombre 
where id = (select t.id from torneo t join videojuego v on t.id_videojuego = v.id group by v.id having count(*) > 2);  










