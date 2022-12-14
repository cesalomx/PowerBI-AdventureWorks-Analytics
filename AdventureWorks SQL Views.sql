USE [AdventureWorks2019]

go

SET ansi_nulls ON

go

SET quoted_identifier ON

go

-- [Purchasing_PowerBI]
ALTER VIEW [dbo].[Purchasing_PowerBI]
AS
  SELECT a.purchaseorderid             AS OrderID,
         b.orderdate,
         b.shipdate,
         a.duedate,
         a.productid,
         d.NAME                        AS DescriptionName,
         a.orderqty                    AS RequestedQuantity,
         -- Changed to requested quantity on 01/Oct/2022
         a.receivedqty,
         a.rejectedqty                 AS ReturnedQty,
         a.unitprice,
         a.linetotal                   AS Total,
         b.vendorid,
         e.NAME                        AS Vendor,
         c.averageleadtime,
         Dense_rank()
           OVER(
             ORDER BY a.orderqty DESC) AS RequestedRank
  FROM   purchasing.purchaseorderdetail AS a
         INNER JOIN purchasing.purchaseorderheader AS b
                 ON a.purchaseorderid = b.purchaseorderid
         INNER JOIN purchasing.productvendor AS c
                 ON a.productid = c.productid
         INNER JOIN production.product AS d
                 ON c.productid = d.productid
         INNER JOIN purchasing.vendor AS e
                 ON b.vendorid = e.businessentityid

go

-- [Inventory_PowerBI]
ALTER VIEW [dbo].[Inventory_PowerBI]
AS
  SELECT a.modifieddate AS EntryDate,
         a.productid,
         b.NAME         AS Product,
         d.productmodelid,
         d.NAME         AS ProductLine,
         c.locationid,
         c.NAME         AS Location,
         a.quantity
  FROM   production.productinventory AS a
         JOIN production.product AS b
           ON a.productid = b.productid
         JOIN production.location AS c
           ON a.locationid = c.locationid
         JOIN production.productmodel AS d
           ON b.productmodelid = d.productmodelid

go

-- [Production_PowerBI]
ALTER VIEW [dbo].[Production_PowerBI]
AS
  SELECT a.workorderid,
         a.startdate,
         a.enddate,
         a.duedate,
         d.locationid,
         d.NAME       AS Location,
         a.productid,
         b.NAME       AS ProductName,
         e.productmodelid,
         e.NAME       AS ProductModel,
         a.orderqty   AS QUANTITY,
         a.stockedqty AS Stocked,
         b.standardcost,
         b.listprice
  FROM   production.workorder AS a
         JOIN production.product AS b
           ON a.productid = b.productid
         JOIN production.workorderrouting AS c
           ON a.workorderid = c.workorderid
         JOIN production.location AS d
           ON c.locationid = d.locationid
         JOIN production.productmodel AS e
           ON b.productmodelid = e.productmodelid

go

-- [HR_PowerBI]
ALTER VIEW [dbo].[HR_PowerBI]
AS
  SELECT a.businessentityid,
         a.startdate                    AS DateOfJoining,
         a.enddate                      AS LastWorkingDay,
         b.groupname,
         b.NAME                         AS DepartmentName,
         c.firstname + ' ' + c.lastname AS EmployeeName,
         d.jobtitle                     AS TSR_Role,
         d.gender,
         d.maritalstatus,
         d.birthdate
  FROM   humanresources.employeedepartmenthistory AS a
         JOIN humanresources.department AS b
           ON a.departmentid = b.departmentid
         JOIN person.person AS c
           ON a.businessentityid = c.businessentityid
         JOIN humanresources.employee AS d
           ON a.businessentityid = d.businessentityid

go

-- [Sales_PowerBI]
ALTER VIEW [dbo].[Sales_PowerBI]
AS
  SELECT sales.salesorderdetail.salesorderid      AS OrderID,
         sales.salesorderdetail.orderqty          AS Quantity,
         sales.salesorderdetail.productid,
         production.product.NAME                  AS ProductName,
         sales.salesorderdetail.unitprice,
         sales.salesorderdetail.unitpricediscount AS Discount,
         sales.salesorderdetail.linetotal         AS Total,
         sales.salesorderheader.status,
         sales.salesorderheader.orderdate,
         sales.salesorderheader.customerid,
         sales.salesorderheader.salespersonid,
         person.person.firstname + ' '
         + person.person.lastname                 AS SalesPersonName,
         sales.salesterritory.territoryid,
         sales.salesterritory.NAME
  FROM   sales.salesorderdetail
         INNER JOIN sales.salesorderheader
                 ON sales.salesorderdetail.salesorderid =
                    sales.salesorderheader.salesorderid
         INNER JOIN production.product
                 ON sales.salesorderdetail.productid =
                    production.product.productid
         INNER JOIN sales.salesterritory
                 ON sales.salesorderheader.territoryid =
                    sales.salesterritory.territoryid
                    AND sales.salesorderheader.territoryid =
                        sales.salesterritory.territoryid
                    AND sales.salesorderheader.territoryid =
                        sales.salesterritory.territoryid
         LEFT OUTER JOIN person.person
                      ON sales.salesorderheader.salespersonid =
                         person.person.businessentityid

go

-- [Customer_PowerBI]
ALTER VIEW [Sales].[Customer_PowerBI]
AS
  SELECT p.[businessentityid],
         p.[title],
         p.[firstname],
         p.[middlename],
         p.[lastname],
         p.[suffix],
         pp.[phonenumber],
         pnt.[name] AS [PhoneNumberType],
         ea.[emailaddress],
         p.[emailpromotion],
         at.[name]  AS [AddressType],
         a.[addressline1],
         a.[addressline2],
         a.[city],
         [StateProvinceName] = sp.[name],
         a.[postalcode],
         [CountryRegionName] = cr.[name],
         p.[demographics]
  FROM   [Person].[person] p
         INNER JOIN [Person].[businessentityaddress] bea
                 ON bea.[businessentityid] = p.[businessentityid]
         INNER JOIN [Person].[address] a
                 ON a.[addressid] = bea.[addressid]
         INNER JOIN [Person].[stateprovince] sp
                 ON sp.[stateprovinceid] = a.[stateprovinceid]
         INNER JOIN [Person].[countryregion] cr
                 ON cr.[countryregioncode] = sp.[countryregioncode]
         INNER JOIN [Person].[addresstype] at
                 ON at.[addresstypeid] = bea.[addresstypeid]
         INNER JOIN [Sales].[customer] c
                 ON c.[personid] = p.[businessentityid]
         LEFT OUTER JOIN [Person].[emailaddress] ea
                      ON ea.[businessentityid] = p.[businessentityid]
         LEFT OUTER JOIN [Person].[personphone] pp
                      ON pp.[businessentityid] = p.[businessentityid]
         LEFT OUTER JOIN [Person].[phonenumbertype] pnt
                      ON pnt.[phonenumbertypeid] = pp.[phonenumbertypeid]
  WHERE  c.storeid IS NULL;

go 