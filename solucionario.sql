-- Pregunta 1

create database reclamos
go

use reclamos
go

create table estudiantes(
	codigo nchar(3) not null,
	nombre nvarchar(10) not null,
	apellido_paterno nvarchar(15) not null,
	apellido_materno nvarchar(15) not null,
	fecha_nacimiento date not null,
	direccion nvarchar(40) not null,
	categoria nvarchar(20) not null,
	constraint pk_estudiantes primary key (codigo)
)
go

create table cursos (
	codigo	int not null,
	nombre nvarchar(25) not null,
	vacantes int null,
	matriculados int null,
	profesor nvarchar(50) not null,
	costo money not null,
	creditos int not null,
	constraint pk_cursos primary key (codigo)
)
go
