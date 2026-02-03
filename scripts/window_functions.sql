--comparando groupby e window function
--descobrindo o total de vendas por cliente por meio do group by
SELECT
    SalesOrderID
    ,ProductID
    ,FORMAT(ModifiedDate, 'dd/MM/yyyy') AS OrderDate
    ,SUM(OrderQty) AS TotalOrderQty
FROM SALES.SalesOrderDetail
GROUP BY SalesOrderID, ProductID, ModifiedDate;

-- Descobrindo o total de vendas em todos os pedidos
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS OrderDate
    ,SalesOrderID
    ,ProductID
    ,SUM(OrderQty) OVER (PARTITION BY ProductID) AS TotalOrderQty
FROM Sales.SalesOrderDetail
ORDER BY ProductID ASC;

-- Descobrindo o total de vendas por quantidade de produtos em todos os pedidos
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS OrderDate
    ,SalesOrderID
    ,ProductID
    ,OrderQty
    ,SUM(OrderQty) OVER () AS  TotalOrderQty
    ,SUM(OrderQty) OVER (PARTITION BY ProductID) AS TotalOrderbyProductID
FROM Sales.SalesOrderDetail
ORDER BY ProductID ASC;

-- Descobrindo o total de vendas por quantidade de produtos e territorio em todos os pedidos
SELECT
    FORMAT(OD.ModifiedDate, 'dd/MM/yyyy') AS OrderDate
    ,OH.TerritoryID
    ,OD.SalesOrderID
    ,OD.ProductID
    ,OD.OrderQty
    ,SUM(OD.OrderQty) OVER () AS  TotalOrderQty
    ,SUM(OD.OrderQty) OVER (PARTITION BY ProductID, TerritoryID) AS TotalOrderbyProductID_TerritoryID
FROM Sales.SalesOrderDetail OD
    INNER JOIN SALES.SalesOrderHeader OH ON OD.SalesOrderID = OH.SalesOrderID
ORDER BY TerritoryID ASC;

--comparação com o group by
SELECT
    FORMAT(OD.ModifiedDate, 'dd/MM/yyyy') AS OrderDate
    ,OH.TerritoryID
    ,OD.SalesOrderID
    ,OD.ProductID
    ,OD.OrderQty
    --,SUM(OD.OrderQty) OVER() AS  TotalOrderQty
    --,SUM(OD.OrderQty) OVER (PARTITION BY ProductID, TerritoryID) AS TotalOrderbyProductID_TerritoryID
FROM Sales.SalesOrderDetail OD
    INNER JOIN SALES.SalesOrderHeader OH ON OD.SalesOrderID = OH.SalesOrderID
GROUP BY OH.TerritoryID, OD.SalesOrderID, OD.ProductID, OD.OrderQty, OD.ModifiedDate
ORDER BY TerritoryID ASC;

--utilizando rank() para classificar o maior numero de vendas ordenadas por quantidade de vendas
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    ,SalesOrderID
    ,ProductID
    ,OrderQty
    ,RANK() OVER ( ORDER BY OrderQty DESC) RankOrder
FROM Sales.SalesOrderDetail;

--utilizando rows, current row e following para calcular o total de vendas por produto
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    ,SalesOrderID
    ,ProductID
    ,OrderQty
    ,SUM(OrderQty) OVER (PARTITION BY ProductID ORDER BY ModifiedDate
    ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS TotalOrderQty
FROM sales.SalesOrderDetail;

--totalizando a quantidade de vendas ordernadas por produto e data de modificação
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    ,SalesOrderID
    ,ProductID
    ,OrderQty
    ,SUM(OrderQty) OVER (PARTITION BY ProductID ORDER BY ModifiedDate) AS TotalOrderQty
FROM sales.SalesOrderDetail;

--encontrando a quantidade de vendas do id do pedido com CTE + window function
WITH salesorderdatails AS (
SELECT
    FORMAT(ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    ,SalesOrderID
    ,ProductID
    ,OrderQty
    ,SUM(OrderQty) OVER (PARTITION BY ProductID ORDER BY ModifiedDate) AS TotalOrderQty
FROM sales.SalesOrderDetail
 )

 SELECT *
 FROM salesorderdatails
 WHERE SalesOrderID = 63334
 ORDER BY Orderdate DESC;

 --encontrando a quantidade de vendas acima de 10 por id do pedido com CTE + window function
WITH salesorderdatails AS (
SELECT
    FORMAT(SOD.ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    ,SOD.SalesOrderID
    ,SOD.ProductID
    ,SOD.OrderQty
    ,P.Name AS ProductName
    ,PS.Name AS ProductSubCategoryName
    ,SUM(SOD.OrderQty) OVER (PARTITION BY SOD.ProductID ORDER BY SOD.ModifiedDate) AS TotalOrderQty
FROM sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
INNER JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
 )

SELECT *
FROM salesorderdatails
WHERE OrderQty >= 10
ORDER BY Orderdate DESC; 


--selecionando e rankeando os produtos mais vendidos
SELECT
    FORMAT(SOD.ModifiedDate, 'dd/MM/yyyy') AS Orderdate
    --,SOD.SalesOrderID
    ,SOD.ProductID
    ,SOD.OrderQty
    ,P.Name AS ProductName
    ,PS.Name AS ProductSubCategoryName
    ,RANK() OVER (ORDER BY SUM(SOD.OrderQty) DESC) AS RankOrder
FROM sales.SalesOrderDetail SOD
INNER JOIN Production.Product P ON SOD.ProductID = P.ProductID
INNER JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
GROUP BY SOD.SalesOrderID, SOD.ProductID, SOD.OrderQty, P.Name, PS.Name, SOD.ModifiedDate

