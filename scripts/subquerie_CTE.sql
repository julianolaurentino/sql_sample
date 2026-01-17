--todos os produtos cadastrados que tem o preço de venda maior que a média 438.66
--caso a tabela sofra alterações durante o tempo, a query não precisará ser alterada
--pois a subquery irá retornar a média atualizada
SELECT *
FROM  AdventureWorks.Production.Product p 
WHERE ListPrice > (SELECT AVG(ListPrice) AS AvgListPrice FROM AdventureWorks.Production.Product);

--todos os funcionários que tem o cargo de Design Engineer
SELECT
    FirstName
FROM [AdventureWorks2017].[Person].[Person]
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM [AdventureWorks2017].[HumanResources].[Employee] WHERE JobTitle = 'Design Engineer');

--alternativa com INNER JOIN
--podemos usar o actual plan para ver a diferença de performance quando usamos subqueries
SELECT
    PP.FirstName
FROM [AdventureWorks2017].[Person].[Person] PP
INNER JOIN [AdventureWorks2017].[HumanResources].[Employee] HE
    ON PP.BusinessEntityID = HE.BusinessEntityID
WHERE HE.JobTitle = 'Design Engineer';

--select de todos os endereços que estão no estado de Alberta e agrupando por cidade
SELECT *
FROM [AdventureWorks2017].[Person].[Address]
WHERE StateProvinceID = (SELECT StateProvinceID FROM [AdventureWorks2017].[Person].[StateProvince] WHERE Name = 'Alberta')
ORDER BY city ASC;

--Listar produtos que nunca foram vendidos
SELECT
    ProductID
    ,Name as product_name
FROM [AdventureWorks2017].[Production].[Product]
WHERE ProductID NOT IN (SELECT ProductID FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]);

--Listar todos os clientes que fizeram pedidos com valor maior que 10.000
SELECT
    CustomerID
    ,PersonID
    ,territoryID
FROM [Sales].[Customer]
WHERE CustomerID IN (SELECT CustomerID FROM [Sales].[SalesOrderHeader] WHERE SubTotal > 10.000);

--listando os funcionários que trabalham no departamento de 'Sales'.
--ajustando o login do usuário para exibir apenas o nome do usuário
SELECT
    HE.BusinessEntityID
    --,HE.LoginID
    ,SUBSTRING(LoginID, CHARINDEX('\', LoginID) + 1, LEN(LoginID)) AS login
    ,HEDH.DepartmentID
    ,HD.Name
FROM HumanResources.Employee HE
INNER JOIN HumanResources.EmployeeDepartmentHistory HEDH
    ON HE.BusinessEntityID = HEDH.BusinessEntityID
INNER JOIN HumanResources.Department HD
    ON HEDH.DepartmentID = HD.DepartmentID
WHERE HEDH.DepartmentID = (SELECT DepartmentID FROM HumanResources.Department WHERE Name = 'Sales');

--Exibir os fornecedores que não possuem produtos cadastrados no banco de dados.
SELECT
    Name
    ,AccountNumber
    ,BusinessEntityID
FROM Purchasing.Vendor
WHERE BusinessEntityID NOT IN (SELECT BusinessEntityID FROM Purchasing.ProductVendor);


--A CTE ProdutosMaisCaros filtra produtos com preço maior que 0.
--Depois, a consulta principal exibe os 100 mais caros ordenados por preço.
WITH ProdutosMaisCaros AS (
    SELECT Name, ListPrice
    FROM Production.Product
    WHERE ListPrice > 0
)
SELECT TOP 100 *
FROM ProdutosMaisCaros
ORDER BY ListPrice DESC;

--O primeiro SELECT retorna o funcionário base.
--O UNION ALL é usado para unir o resultado do SELECT com a própria CTE Hierarquia.
--O segundo SELECT retorna todos os funcionários que estão na mesma hierarquia.
WITH Hierarquia AS (
    SELECT BusinessEntityID
    ,NationalIDNumber
    ,JobTitle
    FROM HumanResources.Employee
    WHERE BusinessEntityID >= 1  -- Começa por um funcionário específico

    UNION ALL

    SELECT E.BusinessEntityID, E.NationalIDNumber, E.JobTitle
    FROM HumanResources.Employee E
    INNER JOIN Hierarquia H
        ON E.NationalIDNumber = H.BusinessEntityID
)
SELECT * FROM Hierarquia;

--A CTE PedidosNumerados usa ROW_NUMBER() para numerar os pedidos por cliente.
--A consulta principal filtra os 3 mais recentes (NumeroPedido <= 3).
WITH PedidosNumerados AS (
    SELECT CustomerID, SalesOrderID, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS NumeroPedido
    FROM AdventureWorks.Sales.SalesOrderHeader
)
SELECT * 
FROM PedidosNumerados
WHERE NumeroPedido <= 3;

-- CTE TotalPorCliente soma o total gasto por cliente.
--A consulta principal filtra os clientes que gastaram acima da média.
WITH TotalPorCliente AS (
    SELECT CustomerID
    ,SUM(TotalDue) AS TotalGasto
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT *
FROM TotalPorCliente
WHERE TotalGasto > (SELECT AVG(TotalGasto) FROM TotalPorCliente);


-- CTE avglistprice calcula a média de ListPrice.
--A consulta principal exibe os produtos com ListPrice acima da média.
WITH avglistprice AS (
    SELECT 
        ProductID
        ,ListPrice
    FROM Production.Product
    WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)
)
SELECT *
FROM avglistprice;

-- CTE vendasporprodutos calcula o total de vendas por produto.
--A consulta principal exibe os 100 produtos mais vendidos.
WITH vendasporprodutos AS (
    SELECT
        SSO.ProductID
        ,PP.Name as product
        ,COUNT(*) AS TotalVendas
    FROM sales.SalesOrderDetail SSO
    INNER JOIN Production.Product PP
        ON SSO.ProductID = PP.ProductID
    GROUP BY SSO.ProductID
            ,PP.Name
)
SELECT TOP 100 *
FROM vendasporprodutos
ORDER BY TotalVendas DESC;

-- CTE funcionarioscontratados filtra funcionários contratados após 2010.
WITH funcionarioscontratados AS (
    SELECT
        BusinessEntityID
        ,JobTitle
        ,HireDate
    FROM HumanResources.Employee
    WHERE YEAR(HireDate) > 2010
)

SELECT TOP 10 *
FROM funcionarioscontratados
ORDER BY HireDate DESC;

-- CTE qtdpedidos calcula a quantidade de pedidos por cliente.
WITH qtdpedidos AS (
    SELECT
        CustomerID
        ,COUNT(*) AS TotalPedidos
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT *
FROM qtdpedidos
--WHERE TotalPedidos > 5
ORDER BY TotalPedidos DESC;

-- CTE itensmaisvendidos calcula a quantidade de vendas por produto.
-- A consulta principal exibe os 3 produtos mais vendidos.
WITH itensmaisvendidos AS (
    SELECT
        SSO.ProductID
        ,PP.Name
        ,COUNT(*) AS TotalVendido
    FROM Sales.SalesOrderDetail SSO
    INNER JOIN Production.Product PP
        ON SSO.ProductID = PP.ProductID
    GROUP BY SSO.ProductID
        ,PP.Name
)
SELECT TOP 3 *
FROM itensmaisvendidos
ORDER by TotalVendido DESC;

-- CTE totalgastocliente calcula o total gasto por cliente.
-- A consulta principal exibe os clientes que gastaram acima da média.
WITH TotalGastoCliente AS (
    SELECT
        CustomerID
        ,AVG(TotalDue) AS TotalGasto
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)

SELECT *
FROM totalgastocliente
WHERE TotalGasto > (SELECT AVG(TotalGasto) FROM totalgastocliente);

--Criar uma CTE para calcular o salário médio por departamento 
--e exibir a diferença de cada funcionário em relação a essa média.
WITH departmentsalary AS (
SELECT 
    E.BusinessEntityID
    ,E.JobTitle
    ,E.OrganizationLevel
    ,DH.DepartmentID
    ,PH.Rate AS salary
    ,AVG(PH.Rate) OVER(PARTITION BY DH.DepartmentID) AS salaryavg
FROM HumanResources.Employee E
INNER JOIN HumanResources.EmployeePayHistory PH ON E.BusinessEntityID = PH.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory DH ON E.BusinessEntityID = DH.BusinessEntityID
)

SELECT  
    BusinessEntityID
    ,JobTitle
    ,DepartmentID
    ,OrganizationLevel
    ,(salary - salaryavg) AS avgdiff
FROM departmentsalary
ORDER BY DepartmentID, avgdiff DESC

SELECT
    BusinessEntityID
    ,JobTitle
    ,Gender
    ,SalariedFlag
FROM HumanResources.Employee;

--Criar uma CTE para contar as vendas de cada produto 
--e exibir os 5 mais vendidos por categoria.
WITH VendasPorProduto AS (
    SELECT 
        P.ProductID,
        P.Name AS Produto,
        PS.Name AS Categoria,
        COUNT(SD.SalesOrderID) AS TotalVendas,
        RANK() OVER (PARTITION BY PS.Name ORDER BY COUNT(SD.SalesOrderID) DESC) AS Ranking
    FROM Sales.SalesOrderDetail SD
    JOIN Production.Product P ON SD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
    GROUP BY P.ProductID, P.Name, PS.Name
)
SELECT * 
FROM VendasPorProduto
WHERE Ranking <= 5
ORDER BY Categoria, Ranking;

--Criar uma CTE para calcular a quantidade de compras por cliente 
--e listar aqueles que compraram acima da média geral.
WITH totalqtdsales AS (
SELECT
    CustomerID
    ,COUNT(SalesOrderNumber) AS qtdsales
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
)
SELECT *
FROM totalqtdsales
WHERE qtdsales > (SELECT AVG(qtdsales) FROM totalqtdsales)
ORDER BY qtdsales DESC;

--Criando uma CTE recursiva para adicionar dias a partir de 2025-01-01
--até 2026-01-01 com o maximo de recursividade em 366 linhas
WITH tabeladias AS(
SELECT 
    CAST('2025-01-01' AS DATE) AS dias
    UNION ALL 
    SELECT DATEADD( DAY, 1, dias) FROM tabeladias
    WHERE dias < '2026-01-01'
)

SELECT *
FROM tabeladias
OPTION (MAXRECURSION 366)


--Criar uma CTE para calcular a quantidade de vendas por produto
--e exibir os 10 produtos mais vendidos com quantidade acima da média.
SELECT TOP 10
    SalesOrderID AS OrderID
    ,SUM(OrderQty) AS TotalOrderQty
FROM AdventureWorks.Sales.SalesOrderDetail
WHERE OrderQty > (SELECT AVG(OrderQty) FROM AdventureWorks.Sales.SalesOrderDetail)
GROUP BY SalesOrderID
ORDER BY 2 DESC;

