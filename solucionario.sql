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

create table auditorias_matriculas (
	codigo int not null identity(1,1),
	fecha_registro date null,
	codigo_matricula int null,
	descripcion nvarchar(50) null,
	usuario nvarchar(50) null,
	constraint pk_auditorias_matriculas primary key (codigo)
)
go

create procedure insertar_matricula
	@codigo_estudiante nchar(3),
	@codigo_curso int,
	@horas int,
	@mensualidad money,
	@control_proceso nvarchar(15) = 'Reservado'
as
begin
	begin try
		begin transaction
			insert into matriculas (codigo_estudiante, codigo_curso, horas, fecha_reserva,
			mensualidad, control_proceso)
			values (@codigo_estudiante, @codigo_curso, @horas, getdate(), @mensualidad, @control_proceso)
			print ('Proceso de matrícula conforme')
		commit 
	end try
	begin catch
		print error_message()		
		rollback transaction
	end catch

end
go


create procedure actualizar_matricula
	@codigo_matricula int,
	@control_proceso nvarchar(15) = 'Matriculado',
	@fecha_matricula date
as
begin
	begin try
		begin transaction
			if (select count(*) from matriculas where codigo = @codigo_matricula and control_proceso = 'Reservado') = 0  
			begin
				update matriculas 
				set control_proceso = @control_proceso, fecha_matricula = getdate()
				where codigo = @codigo_matricula and control_proceso = 'Reservado'
				print ('Proceso de matrícula actualizado')
				commit transaction
			end 
			else 
			begin
				print ('La matrícula ya se encuentra en estado de matriculado')
				rollback
			end		
	end try
	begin catch 
		print error_message()
		rollback 
	end catch
end
go


create trigger tri_auditorias_matriculas on matriculas
for insert, update
as

begin

	if exists  (select * from inserted)
	begin
		if exists (select * from deleted)
		begin
			insert into auditorias_matriculas (codigo_matricula,descripcion, fecha_registro, usuario)
			select codigo, 'Matricula Actualizada', getdate(), suser_sname()  from inserted 
		end
		else
		begin
			insert into auditorias_matriculas (codigo_matricula,descripcion, fecha_registro, usuario)
			select codigo, 'Matricula Reservada', getdate(), suser_sname()  from inserted 
		end
		
	end
end
go
