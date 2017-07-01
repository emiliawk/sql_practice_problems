use NotrhwindMySQL;

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

