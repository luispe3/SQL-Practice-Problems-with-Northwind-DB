-- 1. Which shippers do we have?
SELECT * 
FROM Shippers

-- 2. Certain fields from Categories
SELECT CategoryName, Description
FROM Categories

-- 3. Sales Representatives
SELECT FirstName, LastName, HireDate
FROM Employees
WHERE title = 'Sales Representative'

-- 4. Sales Representatives in the United StatesSELECT FirstName, LastName, HireDate
FROM Employees
WHERE title = 'Sales Representative' AND country = 'USA'

-- 5. Orders placed by specific EmployeeID
SELECT OrderID, OrderDate
FROM orders
WHERE EmployeeID = 5

-- 6. Suppliers and ContactTitles
SELECT SupplierID, ContactName, ContactTitle
FROM Suppliers
WHERE ContactTitle NOT IN ('Marketing Manager')

-- 7. Products with "queso" in ProductName
SELECT ProductID, ProductName
FROM Products
WHERE ProductName LIKE '%queso%'

-- 8. Orders shipping to France or Belgium
SELECT OrderID, CustomerID, ShipCountry
FROM Orders
WHERE ShipCountry IN ('Belgium', 'France')

-- 9. Orders shipping to any country in Latin America
SELECT OrderID, CustomerID, ShipCountry
FROM Orders
WHERE ShipCountry IN ('Brazil','Mexico','Argentina','Venezuela')

-- 10. Employees, in order of age
SELECT FirstName, LastName, Title, BirthDate
FROM Employees
Order BY BirthDate ASC

-- 11. Showing only the Date with a DateTime field
SELECT FirstName, LastName, Title, CONVERT(DATE,BirthDate)
FROM Employees
Order BY BirthDate ASC

-- 12. Employees Full Name
SELECT FirstName, LastName, FirstName +' '+ LastName as FullName
FROM Employees

-- 13. OrderDetails amount per line item
SELECT OrderID, ProductID, UnitPrice, Quantity, (UnitPrice * Quantity) as TotalPrice
FROM [Order Details]

-- 14. How many customers?
SELECT COUNT(CustomerID) as TotalCustomers
FROM Customers

-- 15. When was the first order?
SELECT FirstOrder = MIN(OrderDate)
FROM Orders

-- 16. Countries where there are customers
SELECT DISTINCT country
FROM Customers

SELECT country
FROM Customers
GROUP BY country

-- 17. Contact titles for customers
SELECT ContactTitle, COUNT (ContactTitle) as CountTitle
FROM Customers
GROUP BY ContactTitle
ORDER BY CountTitle DESC

-- 18. Products with associated supplier names
SELECT p.ProductID, p.ProductName, s.CompanyName
FROM Products p, Suppliers s
WHERE p.SupplierID = s.SupplierID
ORDER BY ProductID ASC

SELECT p.ProductID, p.ProductName, s.CompanyName as Supplier
FROM Products p
JOIN Suppliers s ON s.SupplierID = p.SupplierID
ORDER BY ProductID ASC

-- 19. Orders and the Shipper that was used
SELECT OrderID, CONVERT(DATE,OrderDate) as OrderDate, CompanyName
FROM Orders
JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
WHERE OrderID < 10300
ORDER BY OrderID ASC

-- 20. Categories, and the total products in each category
SELECT CategoryName, COUNT(ProductID) as TotalProduct
FROM Categories
JOIN Products ON products.CategoryID = categories.CategoryID
GROUP BY CategoryName
ORDER BY TotalProduct DESC

-- 21. Total customers per country/city
SELECT Country, City, Count(CustomerID) as TotalCustomers
FROM Customers
GROUP BY Country, City
ORDER BY TotalCustomers DESC

-- 22. Products that need reordering
SELECT ProductID, ProductName, UnitsInStock, ReorderLevel
FROM Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID ASC

-- 23. Products that need reordering, continued
SELECT ProductID, ProductName, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
FROM Products
WHERE (UnitsInStock+UnitsOnOrder <= ReorderLevel) AND (Discontinued = 0)

-- 24. Customer list by region
SELECT CustomerID, CompanyName, Region
FROM Customers
ORDER BY CASE WHEN Region IS NULL THEN 1 ELSE 0 END, Region ASC, CustomerID ASC

SELECT CustomerID, CompanyName, Region, 
		RegionOrder = CASE WHEN Region IS NULL THEN 1 ELSE 0 END
FROM Customers
ORDER BY RegionOrder ASC, Region ASC, CustomerID ASC

-- 25. High freight charges
SELECT TOP 3 ShipCountry, AVG(Freight) as avgFreight
FROM Orders
GROUP BY ShipCountry
ORDER BY avgFreight DESC

-- 26. High freight charges - 2015
SELECT TOP 3 ShipCountry, AVG(Freight) as avgFreight
FROM Orders
WHERE OrderDate >= '19970101' AND OrderDate < '19980101'
GROUP BY ShipCountry
ORDER BY avgFreight DESC

-- 27. High freight charges with Between
SELECT OrderID, OrderDate, ShipCountry, Freight
FROM Orders
WHERE OrderDate >= '19970101' AND OrderDate < '19980101' AND ShipCountry = 'France'
ORDER BY OrderDate

-- 28. High freight charges - last year
SELECT TOP 3 ShipCountry, AVG(Freight) as avgFreight
FROM Orders
WHERE OrderDate >= DATEADD(yy,-1, (SELECT MAX(OrderDate) FROM Orders))
GROUP BY ShipCountry
ORDER BY avgFreight DESC

-- 29. Inventory list
SELECT Orders.EmployeeID, LastName, Orders.OrderID, ProductName, Quantity
FROM Orders
JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Products ON [Order Details].ProductID = Products.ProductID
ORDER BY OrderID, Products.ProductID

-- 30. Customers with no orders
SELECT Orders.CustomerID, Customers.CustomerID
FROM Orders
RIGHT JOIN Customers ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.CustomerID IS NULL

-- 31. Customers With no orders for EmployeeID 4
SELECT OrderEmployee4.CustomerID, Customers.CustomerID
FROM (SELECT Orders.CustomerID, Orders.EmployeeID
FROM Orders
WHERE Orders.EmployeeID = '4') as OrderEmployee4
RIGHT JOIN Customers ON Customers.CustomerID = OrderEmployee4.CustomerID
WHERE (OrderEmployee4.CustomerID IS NULL)

-- 32. High-value customers
SELECT Customers.CustomerID, Orders.OrderID, Customers.CompanyName, SUM(Quantity * UnitPrice) as TotalOrderAmount
FROM Orders 
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE OrderDate >= '19980101' AND OrderDate < '19990101'
GROUP BY Customers.CustomerID, Customers.CompanyName, Orders.OrderID
HAVING SUM(Quantity * UnitPrice) >= 10000
ORDER BY TotalOrderAmount DESC


-- 33. High-value Customers - Total Orders
SELECT Customers.CustomerID, Customers.CompanyName, SUM(Quantity*UnitPrice) as TotalAmount
FROM Orders
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE OrderDate >= '19980101' AND OrderDate < '19990101'
GROUP BY Customers.CustomerID, Customers.CompanyName
HAVING SUM(Quantity*UnitPrice) >= 15000
ORDER BY TotalAmount DESC

-- 34. High-value customers - with discount
SELECT Customers.CustomerID, Customers.CompanyName, SUM(Quantity*UnitPrice) as TotalAmount, SUM(Quantity*(UnitPrice*(1-Discount))) as TotalAmountDiscount
FROM Orders
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE OrderDate >= '19980101' AND OrderDate < '19990101'
GROUP BY Customers.CustomerID, Customers.CompanyName
HAVING SUM(Quantity*UnitPrice) > 10000
ORDER BY TotalAmountDiscount DESC

-- 35. Month-end orders
SELECT Orders.EmployeeID, Orders.OrderID, Orders.OrderDate
FROM Orders
WHERE OrderDate = DATEADD(mm,1+DATEDIFF(mm,0,OrderDate),-1)

SELECT EmployeeID, OrderID, OrderDate
FROM Orders
WHERE OrderDate = EOMONTH(OrderDate)
ORDER BY EmployeeID, OrderID

-- 36. Orders with many line items
SELECT TOP 10 OrderID, COUNT(ProductID) as TotalItems
FROM [Order Details]
GROUP BY OrderID
ORDER BY TotalItems DESC

-- 37. Orders - random assortment
SELECT TOP 2 PERCENT OrderID
FROM Orders
ORDER BY NEWID()

-- 38. Orders - accidental double-entry


SELECT * FROM [Order Details]




SELECT Orders.CustomerID, COUNT(Orders.OrderID) as NumOrders, SUM([Order Details].UnitPrice*[Order Details].Quantity) as TotalValue
FROM Orders 
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
GROUP BY Orders.CustomerID, Orders.OrderID
HAVING SUM([Order Details].UnitPrice*[Order Details].Quantity) > 10000






