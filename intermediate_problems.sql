use NorthwindMySQL;

# 20
# Categories, and the total products in each category

select c.CategoryName, count(*) as TotalProducts 
from products p 
left join categories c 
using (CategoryID) 
group by c.CategoryName 
order by count(*) desc;

# 21
# Total customers per country/city
select c.Country, c.City, count(*) as TotalCustomer
from customers c
group by c.Country, c.City
order by count(*) desc;

# 22
# Products that need reordering
select p.ProductID, p.ProductName, p.UnitsInStock, p.ReorderLevel 
from products p 
where p.UnitsInStock < p.ReorderLevel 
order by p.ProductID;

# 23
# Products that need reordering, continued
select p.ProductID, p.ProductName, p.UnitsInStock, p.ReorderLevel 
from products p 
where (p.UnitsInStock + p.UnitsOnOrder) <= p.ReorderLevel and p.Discontinued = 0 
order by p.ProductID;

# 24
# Customer list by region
select p.CustomerID, p.CompanyName, p.Region 
from customers p 
order by case when p.Region is null then 1 else 0 end, p.Region, p.CustomerID;

# 25 
# High freight charges
select p.ShipCountry, cast(avg(p.Freight) as decimal(10,4)) as AverageFreight 
from Orders p 
group by p.ShipCountry 
order by avg(p.Freight) desc
limit 3;

# 26
# High freigh charges - 2015
select p.ShipCountry, cast(avg(p.Freight) as decimal(10,4)) as AverageFreight 
from Orders p 
where p.OrderDate >= '20150101' and p.OrderDate < '20160101' 
group by p.ShipCountry 
order by avg(p.Freight) desc 
limit 3;

# 27
# High freight charges with between
select p.ShipCountry, cast(avg(p.Freight) as decimal(10,4)) as AverageFreight 
from Orders p 
where p.OrderDate between '20150101' and '20151231' 
group by p.ShipCountry 
order by avg(p.Freight) desc 
limit 3;

# 28
# High freight charges - last year

set @last_year = (select date_add(max(p.OrderDate), interval -1 year) from orders p);

select p.ShipCountry, cast(avg(p.Freight) as decimal(10,4)) as AverageFreight 
from Orders p 
where p.OrderDate >= @last_year
group by p.ShipCountry 
order by avg(p.Freight) desc 
limit 3;

# 29
# Inventory List

select e.EmployeeID, e.LastName, o.OrderID, p.ProductName, d.Quantity 
from orders o 
inner join OrderDetails d using (OrderID) 
inner join Products p using (ProductID) 
inner join Employees e on o.EmployeeID = e.EmployeeID
order by o.OrderID, p.ProductID;

# 30
# Customers with no orders

select c.CustomerID as Customers_CustomerID, o.CustomerID as Orders_CustomerID 
from Customers c 
left join Orders o 
using (CustomerID) 
where o.CustomerID is null;

# 31
# Customers with no orders for EmployeeID 4

select c.CustomerID, o.CustomerID 
from Customers c 
left join Orders o
on c.CustomerID = o.CustomerID and o.EmployeeID = 4
where o.CustomerID is null;

# alternate solution
select c.CustomerID, b.CustomerID  
from Customers c  
left join  
(select o.CustomerID from orders o where o.EmployeeID = 4) b 
on c.CustomerID = b.CustomerID 
where b.CustomerID is null;

# another alternate solution
select c.CustomerID 
from Customers c 
where c.CustomerID not in (select o.CustomerID from Orders o where o.EmployeeID = 4);
