--selecionando todos os campos da tabela person.person onde o campo lastname é igual a 'miller' e firstname é igual a 'anna'
SELECT *
FROM [AdventureWorks2017].PERSON.PERSON
WHERE Lastname = 'miller' and FirstName = 'anna';

--selecionando todos os campos da tabela production.product onde o campo color é igual a 'red' ou 'blue' alternando com o IN
SELECT *
FROM 
    [AdventureWorks2017].Production.Product
/*WHERE 
    Color = 'red' OR Color = 'blue'*/
WHERE 
    Color IN ('red', 'blue');

--selecionando todos os campos da tabela production.product onde o campo color é diferente de 'red' ou 'black' 
--e listprice é maior que 1500 e menor que 5000
SELECT 
    Name as ProductName
    ,Color
    ,ListPrice
FROM 
    [AdventureWorks2017].Production.Product
WHERE 
    Color IN ('red', 'black')
    AND ListPrice > 1500 AND ListPrice < 5000;

--selecionando todos os campos da tabela production.product onde o campo color é diferente de 'red'
SELECT *
FROM 
    [AdventureWorks2017].Production.Product
WHERE 
    Color <> 'red';

--selecionando todos os campos da tabela production.product onde o campo weight é maior que 500 e menor que 700
SELECT 
    Name
    ,Weight
FROM 
    [AdventureWorks2017].Production.Product
WHERE 
    Weight > 500 AND Weight < 700;

--selecionando todos os campos da tabela humanresources.employee onde o campo maritalstatus é igual a 'M' e salariedflag é igual a 1
SELECT *
FROM 
    [AdventureWorks2017].HumanResources.Employee
WHERE 
    MaritalStatus = 'M' AND SalariedFlag = 1;

--criando um join entre as tabelas person.person e person.emailaddress onde o campo businessentityid é igual
--e o campo firstname é igual a 'Peter' e lastname é igual a 'Krebs'
SELECT 
    PP.FIRSTNAME
    ,PP.LASTNAME
    ,PE.EMAILADDRESS
FROM 
    [AdventureWorks2017].PERSON.PERSON PP
LEFT JOIN [AdventureWorks2017].[Person].EmailAddress PE
    ON PP.BusinessEntityID = PE.BusinessEntityID
    WHERE PP.FirstName = 'Peter' AND PP.LastName = 'Krebs'
