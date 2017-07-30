use NorthwindMySQL;

# 32
# High value customers

select c.CustomerID, c.CompanyName, o.OrderID, cast(sum(d.UnitPrice * d.Quantity) as decimal(10,2)) as TotalOrderAmount 
from Orders o 
left join OrderDetails d using (OrderID) 
left join Customers c using (CustomerID)
where o.OrderDate >= '2016-01-01' and o.OrderDate < '2017-01-01'
group by c.CustomerID, c.CompanyName, o.OrderID
having sum(d.UnitPrice * d.Quantity) >= 10000
order by TotalOrderAmount desc;

# alternative solution
select p.CustomerID, p.CompanyName, p.OrderID, p.TotalOrderAmount from
(select c.CustomerID, c.CompanyName, o.OrderID, cast(sum(d.UnitPrice * d.Quantity) as decimal(10,2)) as TotalOrderAmount 
from Orders o 
left join OrderDetails d using (OrderID) 
left join Customers c using (CustomerID)
where o.OrderDate >= '2016-01-01' and o.OrderDate < '2017-01-01'
group by c.CustomerID, c.CompanyName, o.OrderID) p
where p.TotalOrderAmount >= 10000
order by p.TotalOrderAmount desc;

# 33
# High-value customers - total orders

select c.CustomerID, c.CompanyName, cast(sum(d.UnitPrice * d.Quantity) as decimal(10,2)) as TotalOrderAmount 
from Orders o 
left join OrderDetails d using (OrderID) 
left join Customers c using (CustomerID)
where o.OrderDate >= '2016-01-01' and o.OrderDate < '2017-01-01'
group by c.CustomerID, c.CompanyName
having sum(d.UnitPrice * d.Quantity) >= 15000
order by TotalOrderAmount desc;

# 34
# High value customers - with discount

select c.CustomerID, c.CompanyName, 
cast(sum(d.UnitPrice * d.Quantity) as decimal(10,2)) as TotalWithoutDiscount,
cast(sum((d.UnitPrice - d.UnitPrice * d.Discount) * d.Quantity) as decimal(10,2)) as TotalWithDiscount
from Orders o 
left join OrderDetails d using (OrderID) 
left join Customers c using (CustomerID)
where o.OrderDate >= '2016-01-01' and o.OrderDate < '2017-01-01'
group by c.CustomerID, c.CompanyName
having sum((d.UnitPrice - d.UnitPrice * d.Discount) * d.Quantity) >= 10000
order by TotalWithDiscount desc;

# 35
# Month-end-orders

select o.EmployeeID, o.OrderID, o.OrderDate 
from Orders o
where date(o.OrderDate) = last_day(o.OrderDate)
order by
o.EmployeeID;

# 36
# Orders with many line items

select o.OrderID, count(o.OrderID) as TotalOrderDetails
from Orders o
left join OrderDetails d
using (OrderID)
group by d.OrderID
order by TotalOrderDetails desc
limit 10;

# 37
# Orders - random assortment

# 2% of all rows in Orders table
set @num_rows = (select round(0.02*count(*)) from Orders);

# defined a new procedure to get arround limitations on using a variable with LIMIT
drop procedure if exists percentage_of_rows;
DELIMITER $$
create procedure `percentage_of_rows`(in percentage int)
begin

select 
o.OrderID
from Orders o
order by rand()
limit percentage;

end$$
DELIMITER ;

call percentage_of_rows(@num_rows);

# 38
# Orders - accidental double entry

select o.OrderID 
from OrderDetails o 
where o.Quantity >= 60
group by o.OrderID, o.Quantity
having count(o.OrderID) > 1
order by o.OrderID;

# 39
# Orders - accidental double-entry details

select o.* 
from OrderDetails o 
where o.OrderID in
(select o.OrderID from OrderDetails o where o.Quantity >= 60
group by o.OrderID, o.Quantity
having count(o.OrderID) > 1
order by o.OrderID);

# using CTE
# needs mysql version 8.0
#with cte as (select o.OrderID from OrderDetails o where o.Quantity >= 60
#group by o.OrderID, o.Quantity
#having count(o.OrderID) > 1
#order by o.OrderID)
#select o.* 
#from OrderDetails o 
#where o.OrderID in select OrderID from cte;

# 40
# Orders - accidental double-entry details, derived table

select d.*
from OrderDetails d 
inner join 
(select distinct o.OrderID 
from OrderDetails o 
where o.Quantity >= 60
group by o.OrderID, o.Quantity
having count(o.OrderID) > 1) PotentialProblemOrders
on PotentialProblemOrders.OrderID = d.OrderID
order by d.OrderID, d.ProductID;

# 41
# Late orders

select o.OrderID, o.OrderDate, o.RequiredDate, o.ShippedDate 
from Orders o
where date(o.RequiredDate) <= date(o.ShippedDate)
order by o.OrderID;

# 42
# Late orders - which emloyees?

select o.EmployeeID, e.LastName, count(o.OrderID) as TotalLateOrders
from Orders o
left join Employees e
using (EmployeeID)
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID
order by TotalLateOrders desc;

# 43
# Late orders vs. total orders

select o.EmployeeID, e.LastName, AllOrders.AllOrders, count(o.OrderID) as TotalLateOrders 
from Orders o 
left join
(select o.EmployeeID, count(o.OrderID) as AllOrders
from Orders o
group by o.EmployeeID) AllOrders
on o.EmployeeID = AllOrders.EmployeeID
left join Employees e
on o.EmployeeID = e.EmployeeID
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID;

# 44
# Late orders vs. total orders - missing employee

select e.EmployeeID, e.LastName, AllOrders.AllOrders, LateOrders.LateOrders
from Employees e
left join
(select o.EmployeeID, count(o.OrderID) as AllOrders
from Orders o
group by o.EmployeeID) AllOrders
on e.EmployeeID = AllOrders.EmployeeID
left join
(select o.EmployeeID, count(o.OrderID) as LateOrders
from Orders o
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID) LateOrders
on e.EmployeeID = LateOrders.EmployeeID
order by e.EmployeeID;

# 45
# Late orders vs. total orders - fix null

select e.EmployeeID, e.LastName, ifnull(AllOrders.AllOrders, 0) as AllOrders, ifnull(LateOrders.LateOrders, 0) as LateOrders
from Employees e
left join
(select o.EmployeeID, count(o.OrderID) as AllOrders
from Orders o
group by o.EmployeeID) AllOrders
on e.EmployeeID = AllOrders.EmployeeID
left join
(select o.EmployeeID, count(o.OrderID) as LateOrders
from Orders o
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID) LateOrders
on e.EmployeeID = LateOrders.EmployeeID
order by e.EmployeeID;

# 46
# Late orders vs. total orders - percentage

select e.EmployeeID, e.LastName, ifnull(AllOrders.AllOrders, 0) as AllOrders, ifnull(LateOrders.LateOrders, 0) as LateOrders,
ifnull(LateOrders.LateOrders, 0)* 1.00000000000000/ifnull(AllOrders.AllOrders, 0) as PercentLateOrders
from Employees e
left join
(select o.EmployeeID, count(o.OrderID) as AllOrders
from Orders o
group by o.EmployeeID) AllOrders
on e.EmployeeID = AllOrders.EmployeeID
left join
(select o.EmployeeID, count(o.OrderID) as LateOrders
from Orders o
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID) LateOrders
on e.EmployeeID = LateOrders.EmployeeID
order by e.EmployeeID;

# 47
# Late orders vs. total orders - fix decimal

select e.EmployeeID, e.LastName, ifnull(AllOrders.AllOrders, 0) as AllOrders, ifnull(LateOrders.LateOrders, 0) as LateOrders,
cast(ifnull(LateOrders.LateOrders, 0)* 1.0/ifnull(AllOrders.AllOrders, 0) as decimal(10,2)) as PercentLateOrders
from Employees e
left join
(select o.EmployeeID, count(o.OrderID) as AllOrders
from Orders o
group by o.EmployeeID) AllOrders
on e.EmployeeID = AllOrders.EmployeeID
left join
(select o.EmployeeID, count(o.OrderID) as LateOrders
from Orders o
where date(o.RequiredDate) <= date(o.ShippedDate)
group by o.EmployeeID) LateOrders
on e.EmployeeID = LateOrders.EmployeeID
order by e.EmployeeID;

# 48 and # 49
# Customer grouping

select c.CustomerID, c.CompanyName, cast(totals.TotalOrderAmount as decimal(10,2)) as TotalOrderAmount, 
case 
when totals.TotalOrderAmount <= 1000 then 'Low' 
when totals.TotalOrderAmount > 1000 and totals.TotalOrderAmount <= 5000 then 'Medium' 
when totals.TotalOrderAmount > 5000 and totals.TotalOrderAmount <= 10000 then 'High' 
when totals.TotalOrderAmount > 10000 then 'Very High'
end
as CustomerGroup
from
(select o.CustomerID, sum(d.Quantity * d.UnitPrice) as TotalOrderAmount
from Orders o 
inner join OrderDetails d 
on o.OrderID = d.OrderID and year(o.OrderDate) = 2016
group by o.CustomerID) totals
left join
Customers c
on totals.CustomerID = c.CustomerID;

# 51
# Customer grouping flexible

select c.CustomerID, c.CompanyName, cast(totals.TotalOrderAmount as decimal(10,2)) as TotalOrderAmount, threshold.CustomerGroupName
from
(select o.CustomerID, sum(d.Quantity * d.UnitPrice) as TotalOrderAmount
from Orders o 
inner join OrderDetails d 
on o.OrderID = d.OrderID and year(o.OrderDate) = 2016
group by o.CustomerID) totals
left join
Customers c
on totals.CustomerID = c.CustomerID
left join
CustomerGroupThresholds threshold
on totals.TotalOrderAmount >= threshold.RangeBottom and totals.TotalOrderAmount < threshold.RangeTop
order by c.CustomerID;

# 52
# Countries with suppliers or customers

select distinct c.Country from Customers c
union
select distinct s.Country from Suppliers s
order by Country;

# 53
# Countries with suppliers or customers, version 2

# simulating an outer join in MySQL with the list of countries from the previous problem
select supplier.Country as SupplierCountry, customer.Country as CustomerCountry 
from 
# list of all countries from both tables 
(select distinct c.Country from Customers c
union
select distinct s.Country from Suppliers s
order by Country) allCountries
left join
# countries in Suppliers table
(select distinct s.Country from Suppliers s) supplier
on allCountries.Country = supplier.Country
left join
# countries in Customers table
(select distinct c.Country from Customers c) customer
on allCountries.Country = customer.Country;

# 54
# Countries with suppliers or customers, version 3

select 
allCountries.Country, 
ifnull(supplier.TotalSuppliers, 0) as TotalSuppliers, 
ifnull(customer.TotalCustomers, 0) as TotalCustomers
from 
# list of countries from both tables 
(select distinct c.Country from Customers c
union
select distinct s.Country from Suppliers s
order by Country) allCountries
left join
# suppliers count
(select s.Country, count(*) as TotalSuppliers from Suppliers s group by s.Country) supplier
on allCountries.Country = supplier.Country
left join
# customers count
(select distinct c.Country, count(*) as TotalCustomers from Customers c group by c.Country) customer
on allCountries.Country = customer.Country;

# 55
# First order in each country

# one way of handling the groupwise minimum/maximum problem in MySQL
# create a temporary table and insert ignore on ShipCountry as primary key
drop table if exists FirstOrders;
create temporary table FirstOrders (
ShipCountry VARCHAR(15),
CustomerID VARCHAR(5),
OrderID INT NOT NULL,
OrderDate DATE,
PRIMARY KEY (ShipCountry)
);

insert ignore into FirstOrders
select o.ShipCountry, o.CustomerID, o.OrderID, date(o.OrderDate) from Orders o order by o.ShipCountry, o.OrderID;

select * from FirstOrders;

# another way to get the result without creating a temporary table
select 
ranked.ShipCountry,
ranked.CustomerID,
ranked.OrderID,
date(ranked.OrderDate) as OrderDate
from
(select
# create a computed column that shows the row number for each order partitioned by country
( 
  case o.ShipCountry
  when @curType 
  then @curRow := @curRow + 1 
  else @curRow := 1 and @curType := o.ShipCountry end
) + 1 as rank,
o.ShipCountry,
o.CustomerID,
o.OrderID,
o.OrderDate
from Orders o, (select @curRow := 0, @curType := '') r
order by o.ShipCountry, o.OrderID) ranked
where ranked.rank = 1
order by ranked.ShipCountry;


