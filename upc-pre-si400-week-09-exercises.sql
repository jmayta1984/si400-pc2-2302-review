use [upc-pre-northwind]
/*
 Pregunta 1
 Muestre el nombre del producto y el nombre su categoría para cada producto.
*/

SELECT p.ProductName, c.CategoryName
FROM Products p
         INNER JOIN Categories c ON p.CategoryID = c.CategoryID
go

/*
 Pregunta 2
 Indicar el nombre del producto con la mayor cantidad de órdenes.
*/

create view VTotalOrdersByProduct as
select p.ProductName, count(od.OrderID) as Quantity
from [Order Details] od
         inner join Products p on od.ProductID = p.ProductID
group by p.ProductName
go

select ProductName, Quantity
from VTotalOrdersByProduct
where Quantity = (select max(Quantity) as MaxQuantity from VTotalOrdersByProduct)
go

/*
 Pregunta 3
 Indicar la cantidad de órdenes atendidas por cada empleado (mostrar el nombre y apellido de cada
 empleado).
*/

select concat(e.LastName, ', ', e.FirstName), count(o.OrderID) as Quantity
from Orders o
         inner join Employees e on o.EmployeeID = e.EmployeeID
group by concat(e.LastName, ', ', e.FirstName)
go

/*
 Pregunta 4
 Indicar la cantidad de órdenes realizadas por cada cliente (mostrar el nombre de la compañía de
 cada cliente).
*/

select c.CompanyName, count(o.OrderID) as Quantity
from Orders o
         inner join Customers c on o.CustomerID = c.CustomerID
group by c.CompanyName
go

/*
 Pregunta 5
 Identificar la relación de clientes (nombre de compañía) que no han realizado pedidos.
*/

select c.CompanyName
from Customers c
where c.CustomerID not in (select o.CustomerID from Orders o)
go

/*
 Pregunta 6
 Muestre el código y nombre de todos los clientes (nombre de compañía) que tienen órdenes
 pendientes de despachar.
 */

select c.CustomerID, c.CompanyName
from Customers c
where c.CustomerID in (select o.CustomerID from Orders o where o.ShippedDate is null)
go

/*
 Pregunta 7
 Muestre el código y nombre de todos los clientes (nombre de compañía) que tienen órdenes
 pendientes de despachar, y la cantidad de órdenes con esa característica.
 */

select c.CustomerID, c.CompanyName, count(o.OrderID) as Quantity
from Customers c
         inner join Orders o on c.CustomerID = o.CustomerID
where o.ShippedDate is null
group by c.CustomerID, c.CompanyName
go

/*
 Pregunta 8
 Encontrar los pedidos que debieron despacharse a una ciudad o código postal diferente de la ciudad
 o código postal del cliente que los solicitó. Para estos pedidos, mostrar el país, ciudad y código postal
 del destinatario, así como la cantidad total de pedidos por cada destino.
*/
select c.Country, c.City, c.PostalCode, count(o.OrderID) as Quantity
from Orders o
         inner join Customers c on o.CustomerID = c.CustomerID
where o.ShipCity <> c.City
   or o.ShipPostalCode <> c.PostalCode
group by c.Country, c.City, c.PostalCode
go

/*
 Pregunta 9
 Seleccionar todas las compañías de envío (código y nombre) que hayan efectuado algún despacho a
 México entre el primero de enero y el 28 de febrero de 2018.
 Formatos sugeridos a emplear para fechas:
 • Formatos numéricos de fecha (por ejemplo, '15/4/2018')
 • Formatos de cadenas sin separar (por ejemplo, '20181207')
*/

select s.ShipperID, s.CompanyName
from Shippers s
         inner join Orders o on s.ShipperID = o.ShipVia
where o.ShipCountry = 'Mexico'
  and o.ShippedDate between '20180101' and '20180228'
go

/*
 Pregunta 10
 Mostrar los nombres y apellidos de los empleados junto con los nombres y apellidos de sus respectivos jefes.
 */

select concat(e.LastName, ', ', e.FirstName) as EmployeeName, concat(b.LastName, ' ', b.FirstName) as BossName
from Employees e
         left join Employees b on e.ReportsTo = b.EmployeeID
go

/*
 Pregunta 11
 Mostrar el ranking de venta anual por país de origen del empleado, tomando como base la fecha de
 las órdenes, y mostrando el resultado por año y venta total (descendente).
*/

select e.Country, year(o.OrderDate) as Year, sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total
from Orders o
         inner join Employees e on o.EmployeeID = e.EmployeeID
         inner join [Order Details] od on o.OrderID = od.OrderID
group by e.Country, year(o.OrderDate)
order by year(o.OrderDate) desc, Total desc
go

/*
 Pregunta 12
 Mostrar de la tabla Orders, para los pedidos cuya diferencia entre la fecha de despacho y la fecha de
 la orden sea mayor a 4 semanas, las siguientes columnas:

 OrderId, CustomerId, Orderdate, Shippeddate, diferencia en días, diferencia en semanas y diferencia
 en meses entre ambas fechas
*/

select o.OrderID,
       o.CustomerID,
       o.OrderDate,
       o.ShippedDate,
       datediff(day, o.OrderDate, o.ShippedDate)   as Days,
       datediff(week, o.OrderDate, o.ShippedDate)  as Weeks,
       datediff(month, o.OrderDate, o.ShippedDate) as Months
from Orders o
where datediff(week, o.OrderDate, o.ShippedDate) > 4
go

/*
 Pregunta 13
 La empresa tiene como política otorgar a los jefes una comisión del 0.5% sobre la venta de sus
 subordinados. Calcule la comisión mensual que le ha correspondido a cada jefe por cada año
 (basándose en la fecha de la orden) según las ventas que figuran en la base de datos. Muestre el
 código del jefe, su apellido, el año y mes de cálculo, el monto acumulado de venta de sus
 subordinados, y la comisión obtenida.
*/

select b.EmployeeID,
       b.LastName,
       year(o.OrderDate)                                           as Year,
       month(o.OrderDate)                                          as Month,
       sum(od.UnitPrice * od.Quantity * (1 - od.Discount))         as Total,
       sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) * 0.005 as Commission
from Orders o
         inner join Employees e on o.EmployeeID = e.EmployeeID
         inner join Employees b on e.ReportsTo = b.EmployeeID
         inner join [Order Details] od on o.OrderID = od.OrderID
group by b.EmployeeID, b.LastName, year(o.OrderDate), month(o.OrderDate)
go
