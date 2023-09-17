create schema flota;
--creación de tablas--
create table flota.coche (

matricula VARCHAR(7) primary key,
km_totales INT not null,
id_seguro INT not null,
fecha_compra DATE not null,
id_color INT not null,
id_modelo INT not null,
id_revision INT not null
);


create table flota.seguro (
id INT primary key, 
fecha_alta DATE not null,
id_aseguradora INT not null
);

create table flota.aseguradora (
id serial primary key,
nombre VARCHAR(20) not null
);

create table flota.revision (
id serial primary key,
fecha DATE not null,
km INT not null,
importe FLOAT not null,
id_moneda INT not null
);

create table flota.moneda (
id serial primary key,
nombre VARCHAR(25) not null
);

create table flota.color ( 
id serial primary key,
nombre VARCHAR(15) not null
);

create table flota.modelo (
id serial primary key,
nombre VARCHAR(20) not null,
id_marca INT not null
);

create table flota.marca (
id serial primary key,
nombre VARCHAR(12) not null,
id_grupo INT not null
);

create table flota.grupo (
id serial primary key,
nombre VARCHAR(15) not null
);

--creación de relaciones--
alter table flota.coche add constraint pk_coche_seguro foreign key (id_seguro) references flota.seguro(id);
alter table flota.coche add constraint pk_coche_revision foreign key (id_revision) references flota.revision(id);
alter table flota.coche add constraint pk_coche_color foreign key (id_color) references flota.color(id);
alter table flota.coche add constraint pk_coche_modelo foreign key (id_modelo) references flota.modelo(id);
alter table flota.seguro add constraint pk_seguro_aseguradora foreign key (id_aseguradora) references flota.aseguradora(id);
alter table flota.revision add constraint pk_revision_moneda foreign key (id_moneda) references flota.moneda(id);
alter table flota.modelo add constraint pk_modelo_marca foreign key (id_marca) references flota.marca(id);
alter table flota.marca add constraint pk_marca_grupo foreign key (id_grupo)references flota.grupo(id);

--inserción de datos--
insert into flota.aseguradora (nombre)select aseguradora as nombre from flota.coches c group by aseguradora;
insert into flota.moneda (nombre)select moneda as nombre from flota.coches c group by moneda;

--cambio de tamaño de varchar por discrepancia con el tamaño de los datos importados--
alter table flota.grupo alter column nombre type VARCHAR(35);

--inserción de datos--
insert into flota.grupo (nombre)select grupo as nombre from flota.coches c group by grupo;
insert into flota.color (nombre)select color as nombre from flota.coches c group by color;

insert into flota.marca (nombre, id_grupo)
select c.marca, fg.id
from flota.coches c 
inner join flota.grupo fg on fg.nombre = c.grupo 
group by c.marca, fg.id, fg.nombre ;


insert into flota.seguro (fecha_alta, id_aseguradora, id)
select cast(c.fecha_alta_seguro as date), a.id, c.n_poliza
from flota.coches c 
inner join flota.aseguradora a on a.nombre = c.aseguradora 
group by c.n_poliza , c.fecha_alta_seguro, a.id;


insert into flota.revision (fecha, km, importe, id_moneda)
select cast(c.fecha_revision as date), c.kms_revision, c.importe_revision, m.id 
from flota.coches c
inner join flota.moneda m on m.nombre = c.moneda 
group by c.fecha_revision , c.kms_revision , c.importe_revision ,m.id ;

insert into flota.modelo (nombre, id_marca)
select c.modelo, ma.id
from flota.coches c 
inner join flota.marca ma on ma.nombre = c.marca 
group by c.modelo , ma.id;



insert into flota.coche (matricula, km_totales, fecha_compra, id_color, id_modelo, id_revision, id_seguro)
select c.matricula, max(cc.kms_totales), max(cast(cc.fecha_compra as date)), max(co.id), max(mo.id), max(r.id), max(s.id)
from (select distinct matricula, kms_totales, cast(fecha_compra as date) from flota.coches) c
inner join flota.coches cc on c.matricula = cc.matricula 
inner join flota.color co on co.nombre = cc.color
inner join flota.modelo mo on mo.nombre = cc.modelo
inner join flota.revision r on r.km = cc.kms_revision
inner join flota.seguro s on s.id = cc.n_poliza  
group by c.matricula;


select c.matricula  as matricula, cast(c.fecha_compra as date) as "fecha de compra", c.km_totales as "kilometraje", 
mo.nombre as modelo, m.nombre as marca, g.nombre as grupo, co.nombre as color, se.id as "número de poliza", a.nombre as aseguradora
from flota.coche c
inner join flota.modelo mo on mo.id = c.id_modelo 
inner join flota.marca m on m.id = mo.id_marca
inner join flota.grupo g on g.id = m.id_grupo
inner join flota.color co on co.id = c.id_color 
inner join flota.seguro se on se.id = c.id_seguro 
inner join flota.aseguradora a on a.id = se.id_aseguradora
order by matricula;
