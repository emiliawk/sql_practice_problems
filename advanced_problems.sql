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
select p.CustomerID, p.CompanyName, p.TotalOrderAmount from
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

select c.CustomerID, c.CompanyName, o.OrderID, cast(sum(d.UnitPrice * d.Quantity) as decimal(10,2)) as TotalOrderAmount 
from Orders o 
left join OrderDetails d using (OrderID) 
left join Customers c using (CustomerID)
where o.OrderDate >= '2016-01-01' and o.OrderDate < '2017-01-01'
group by c.CustomerID, c.CompanyName
having sum(d.UnitPrice * d.Quantity) >= 15000
order by TotalOrderAmount desc;
