DROP DATABASE IF EXISTS NorthwindMySQL;
CREATE DATABASE NorthwindMySQL;
USE NorthwindMySQL;

CREATE TABLE Categories(
CategoryID INT NOT NULL AUTO_INCREMENT,
CategoryName VARCHAR(15) NOT NULL,
Description TEXT,
PRIMARY KEY (CategoryID),
UNIQUE CategoryName (CategoryName));

CREATE TABLE Customers(
CustomerID VARCHAR(5) NOT NULL,
CompanyName VARCHAR(40) NOT NULL,
ContactName VARCHAR(30),
ContactTitle VARCHAR(30),
Address VARCHAR(60),
City VARCHAR(15),
Region VARCHAR(15),
PostalCode VARCHAR(10),
Country VARCHAR(15),
Phone VARCHAR(24),
Fax VARCHAR(24),
PRIMARY KEY (CustomerID),
INDEX City (City),
INDEX CompanyName (CompanyName),
INDEX PostalCode (PostalCode),
INDEX Region (Region));

CREATE TABLE Employees(
EmployeeID INT NOT NULL AUTO_INCREMENT,
LastName VARCHAR(20) NOT NULL,
FirstName VARCHAR(10) NOT NULL,
Title VARCHAR(30),
TitleOfCourtesy VARCHAR(25),
BirthDate DATETIME,
HireDate DATETIME,
Address VARCHAR(60),
City VARCHAR(15),
Region VARCHAR(15),
PostalCode VARCHAR(10),
Country VARCHAR(15),
HomePhone VARCHAR(24),
Extension VARCHAR(4),
Photo VARCHAR(255),
Notes TEXT,
ReportsTo INT,
PhotoPath VARCHAR(255),
PRIMARY KEY (EmployeeID),
INDEX LastName (LastName));

CREATE TABLE Shippers(
ShipperID INT NOT NULL AUTO_INCREMENT,
CompanyName VARCHAR(40) NOT NULL,
Phone VARCHAR(24),
PRIMARY KEY (ShipperID));

CREATE TABLE Orders(
OrderID INT NOT NULL AUTO_INCREMENT,
CustomerID VARCHAR(5),
EmployeeID INT NOT NULL,
OrderDate DATETIME,
RequiredDate DATETIME,
ShippedDate DATETIME,
ShipVia INT NOT NULL,
Freight FLOAT DEFAULT 0,
ShipName VARCHAR(40),
ShipAddress VARCHAR(60),
ShipCity VARCHAR(15),
ShipRegion VARCHAR(15),
ShipPostalCode VARCHAR(10),
ShipCountry VARCHAR(15),
FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID),
FOREIGN KEY (ShipVia) REFERENCES Shippers (ShipperID),
PRIMARY KEY (OrderID),
INDEX OrderDate (OrderDate),
INDEX ShippedDate (ShippedDate),
INDEX ShipPostalCode (ShipPostalCode));

CREATE TABLE Suppliers(
SupplierID INT NOT NULL AUTO_INCREMENT,
CompanyName VARCHAR(50) NOT NULL,
ContactName VARCHAR(50),
ContactTitle VARCHAR(50),
Address VARCHAR(60),
City VARCHAR(15),
Region VARCHAR(15),
PostalCode VARCHAR(10),
Country VARCHAR(15),
Phone VARCHAR(24),
Fax VARCHAR(24),
HomePage VARCHAR(100),
PRIMARY KEY (SupplierID));

CREATE TABLE Products(
ProductID INT NOT NULL AUTO_INCREMENT,
ProductName VARCHAR(40) NOT NULL,
SupplierID INT NOT NULL,
CategoryID INT NOT NULL,
QuantityPerUnit VARCHAR(20),
UnitPrice FLOAT DEFAULT 0,
UnitsInStock SMALLINT DEFAULT 0,
UnitsOnOrder SMALLINT DEFAULT 0,
ReorderLevel SMALLINT DEFAULT 0,
Discontinued TINYINT DEFAULT 0 NOT NULL,
FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID),
PRIMARY KEY (ProductID),
INDEX ProductName (ProductName));

CREATE TABLE OrderDetails(
OrderID INT NOT NULL,
ProductID INT NOT NULL,
UnitPrice FLOAT DEFAULT 0 NOT NULL,
Quantity SMALLINT DEFAULT 1 NOT NULL,
Discount FLOAT DEFAULT 0 NOT NULL,
FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
FOREIGN KEY (ProductID) REFERENCES Products (ProductID),
PRIMARY KEY (OrderID,ProductID)
);

CREATE TABLE CustomerGroupThresholds(
CustomerGroupName VARCHAR(20) DEFAULT NULL,
RangeBottom DECIMAL(16,5) DEFAULT NULL,
RangeTop DECIMAL(20,5) DEFAULT NULL
);
