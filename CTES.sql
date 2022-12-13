WITH tab_CTE AS (

SELECT
a.PurchaseOrderID AS OrderID,
b.OrderDate,
b.ShipDate,
a.DueDate,
a.ProductID,
d.Name AS DescriptionName,
a.OrderQty AS RequestedQuantity, -- Changed to requested quantity on 01/Oct/2022
DENSE_RANK() OVER(ORDER BY a.OrderQty DESC) AS RequestedRank,
a.ReceivedQty,
a.RejectedQty AS ReturnedQty,
DATEDIFF(day,b.OrderDate,b.ShipDate) AS  Duration,
a.UnitPrice,
a.LineTotal AS Total,
b.VendorID,
e.Name AS Vendor,
c.AverageLeadTime
FROM Purchasing.PurchaseOrderDetail AS a
INNER JOIN Purchasing.PurchaseOrderHeader AS b ON a.PurchaseOrderID = b.PurchaseOrderID
INNER JOIN  Purchasing.ProductVendor AS c ON a.ProductID = c.ProductID
INNER JOIN Production.Product AS d ON c.ProductID = d.ProductID
INNER JOIN Purchasing.Vendor AS e ON b.VendorID = e.BusinessEntityID

) 

SELECT *, "Leadtime" = 
	CASE
		WHEN Duration <= AverageLeadTime THEN 'Yes'
	ELSE 'No'
	END
FROM tab_CTE
