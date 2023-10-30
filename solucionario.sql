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

create table matriculas (
	codigo int not null identity(1,1),
	codigo_estudiante nchar(3) not null,
	codigo_curso int not null,
	horas int not null,
	fecha_reserva date null,
	fecha_matricula date null,
	mensualidad money not null,
	control_proceso nvarchar(15) not null,
	constraint pk_matriculas primary key (codigo),
	constraint fk_estudiantes_matriculas foreign key (codigo_estudiante) references estudiantes (codigo),
	constraint fk_cursos_matriculas foreign key (codigo_curso) references cursos (codigo)
)
