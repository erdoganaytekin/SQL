/* E-Commerce Data and Customer Retention Analysis with SQL */

/*Analyze the data by finding the answers to the questions below:*/

--- 1. Find the top 3 customers who have the maximum count of orders. 

SELECT TOP 3 Cust_ID, Customer_Name, SUM(Order_Quantity) Max_Count_Orders
FROM e_commerce_data
GROUP BY Cust_ID, Customer_Name
ORDER BY SUM(Order_Quantity) DESC;

--- 2. Find the customer whose order took the maximum time to get shipping.

SELECT TOP 1 Customer_Name, DATEDIFF(DAY, Order_Date, Ship_Date) AS DaysTakenForShipping 
FROM e_commerce_data
ORDER BY 2 DESC

-----------------------------------------------------

SELECT Cust_ID, Customer_Name, Order_Date, Ship_Date, DaysTakenForShipping
FROM e_commerce_data
WHERE DaysTakenForShipping = (
							SELECT MAX(DaysTakenForShipping)
							FROM e_commerce_data
							)
-----------------------------------------------------

--- 3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

SELECT DISTINCT(Cust_ID), Customer_Name, Order_Date, 
				CASE WHEN MONTH(Order_Date) = 1 THEN 1 ELSE 0 END AS January,
				CASE WHEN MONTH(Order_Date) = 2 THEN 1 ELSE 0 END AS February,
				CASE WHEN MONTH(Order_Date) = 3 THEN 1 ELSE 0 END AS March,
				CASE WHEN MONTH(Order_Date) = 4 THEN 1 ELSE 0 END AS April,
				CASE WHEN MONTH(Order_Date) = 5 THEN 1 ELSE 0 END AS May,
				CASE WHEN MONTH(Order_Date) = 6 THEN 1 ELSE 0 END AS June,
				CASE WHEN MONTH(Order_Date) = 7 THEN 1 ELSE 0 END AS July,
				CASE WHEN MONTH(Order_Date) = 8 THEN 1 ELSE 0 END AS August,
				CASE WHEN MONTH(Order_Date) = 9 THEN 1 ELSE 0 END AS September,
				CASE WHEN MONTH(Order_Date) = 10 THEN 1 ELSE 0 END AS October,
				CASE WHEN MONTH(Order_Date) = 11 THEN 1 ELSE 0 END AS November,
				CASE WHEN MONTH(Order_Date) = 12 THEN 1 ELSE 0 END AS December
FROM e_commerce_data
WHERE Cust_ID IN (
					SELECT DISTINCT (Cust_ID) 
					FROM e_commerce_data
					WHERE MONTH(Order_Date) = 1
					AND YEAR(Order_Date) = 2011
				 )
AND YEAR(Order_Date) = 2011
GROUP BY Cust_ID, Customer_Name, Order_Date


SELECT MONTH(Order_Date), COUNT(DISTINCT Cust_ID) MONTHLY_NUM_OF_CUST
FROM e_commerce_data A --exists te içerdeki query ile dýþardakini baðlamam gerektiði için A dedim.
WHERE
EXISTS 
	(
	SELECT Cust_ID
	FROM e_commerce_data B
	WHERE YEAR(Order_Date) = 2011
	AND MONTH(Order_Date) = 1
	AND A.Cust_ID = B.Cust_ID
	)
AND YEAR(Order_Date) = 2011
GROUP BY MONTH(Order_Date)

--- 4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.

SELECT *
FROM e_commerce_data
where Cust_ID = 'cust_1000'
order by Order_Date

SELECT Cust_ID, ORD_ID, Order_Date,
		MIN(Order_Date) OVER (PARTITION BY Cust_ID) FIRST_ORDER_DATE,
		DENSE_RANK() OVER(PARTITION BY Cust_ID ORDER BY Order_Date) Dence_Number
FROM e_commerce_data
-- min(order_date) i tekrar eden ayný orderlarý kontrol için aldým.
-- DENCE_RANK() uyguladýktan sonra tkrar eden 3. orderlarý görebiliyorum, þimdi onlarý seçmem lazým.

SELECT DISTINCT
		Cust_ID,
		Order_Date,
		Dence_Number,
		FIRST_ORDER_DATE,
		DATEDIFF(day, FIRST_ORDER_DATE, Order_Date) DAYS_ELAPSED
FROM	
		(
		SELECT	Cust_ID, ORD_ID, Order_Date,
				MIN (Order_Date) OVER (PARTITION BY Cust_ID) FIRST_ORDER_DATE,
				DENSE_RANK () OVER (PARTITION BY Cust_ID ORDER BY Order_Date) Dence_Number
		FROM	e_commerce_data
		) A
WHERE	Dence_Number = 3 
-- Dence_numberlarý 3 olanlarý seçtim. 
-- Soruda istenen de bunlar ile ilk sipariþler arasýnda geçen süre idi. 
-- Where de Dence_Number=3 yaparak; order_date olarak 3.sipariþ tarihlerine ait satýrlarý seçmesini 
 -- ve select içinde DATEDIFF ile bu satýrlarýn first order date ten farklarýný aldým.


 --- 5. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer.

SELECT *
FROM e_commerce_data

SELECT Cust_ID,
		SUM (CASE WHEN PROD_ID = 'Prod_11' THEN Order_Quantity ELSE 0 END) P11,
		SUM (CASE WHEN PROD_ID = 'Prod_14' THEN Order_Quantity ELSE 0 END) P14
FROM e_commerce_data
GROUP BY Cust_ID
-- P11 ve P14 sütunlarý oluþturup SUM ile bu productlara ait sipariþ sayýlarýný altýna yapýþtýrdým diðer productlar 0 olarak geldi.

WITH T1 AS
(
SELECT	Cust_ID,
		SUM (CASE WHEN PROD_ID = 'Prod_11' THEN Order_Quantity ELSE 0 END) P11,
		SUM (CASE WHEN PROD_ID = 'Prod_14' THEN Order_Quantity ELSE 0 END) P14,
		SUM (Order_Quantity) TOTAL_PRODUCT
FROM	e_commerce_data
GROUP BY Cust_ID
HAVING
		SUM (CASE WHEN PROD_ID = 'Prod_11' THEN Order_Quantity ELSE 0 END) >= 1 AND
		SUM (CASE WHEN PROD_ID = 'Prod_14' THEN Order_Quantity ELSE 0 END) >= 1
)
SELECT	Cust_ID, P11, P14, TOTAL_PRODUCT,
		CAST (1.0*P11/TOTAL_PRODUCT AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*P14/TOTAL_PRODUCT AS NUMERIC (3,2)) AS RATIO_P14
FROM T1

/* Customer Segmentation
Categorize customers based on their frequency of visits. The following steps will guide you. If you want, you can track your own way. */

--- 1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW [Visit_Logs_Basic] AS
SELECT  Customer_Name, 
		Cust_ID, 
		DATENAME(YEAR, Order_Date) Visit_Year, 
		DATENAME(MONTH, Order_Date) Visit_Month,
		COUNT(ORD_ID) Order_Numbers
FROM e_commerce_data
GROUP BY Customer_Name, Cust_ID, DATENAME(YEAR, Order_Date), DATENAME(MONTH, Order_Date)

CREATE VIEW [Visit_Logs_Expanded] AS
SELECT  Customer_Name, 
		Cust_ID, 
		DATENAME(YEAR, Order_Date) Visit_Year, 
		DATENAME(MONTH, Order_Date) Visit_Month,
		COUNT(ORD_ID) Order_Numbers,
		Province,
		Region
FROM e_commerce_data
GROUP BY customer_name, Cust_ID, Province, Region, DATENAME(YEAR, Order_Date), DATENAME(MONTH, Order_Date) 
SELECT *
FROM Visit_Logs_Basic
SELECT *
FROM Visit_Logs_Expanded
---------------------------------------------------------

CREATE VIEW Customer_Logs AS

SELECT Cust_ID,
		YEAR (Order_Date) [YEAR],
		MONTH(Order_Date) [MONTH]
FROM e_commerce_data
ORDER BY 1,2,3


SELECT *
FROM Customer_Logs
ORDER BY 1,2,3

--- 2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)

CREATE VIEW [Visit_Logs_Basic] AS

SELECT  customer_name, 
		Cust_ID, 
		DATENAME(YEAR, Order_Date) [Visit Year], 
		DATENAME(MONTH, Order_Date) [Visit Month],
		COUNT(ORD_ID) [Number of Order]
FROM e_commerce_data
GROUP BY customer_name, Cust_ID, DATENAME(YEAR, Order_Date), DATENAME(MONTH, Order_Date) 

CREATE VIEW NUMBER_OF_VISITS AS
SELECT	Cust_ID, [YEAR], [MONTH], COUNT(*) NUM_OF_LOG
FROM	customer_logs
GROUP BY Cust_ID, [YEAR], [MONTH]

SELECT  *,
		DENSE_RANK () OVER (PARTITION BY Cust_ID ORDER BY [YEAR] , [MONTH])
FROM	NUMBER_OF_VISITS

--- 3. For each visit of customers, create the next month of the visit as a separate column.

SELECT *
FROM Visit_Logs_Basic

SELECT *,   
       DENSE_RANK() OVER (PARTITION BY Customer_Name ORDER BY Visit_Month) AS Month 
FROM Visit_Logs_Basic

SELECT *,   
	DENSE_RANK() OVER (ORDER BY Customer_Name) AS Month 
FROM Visit_Logs_Basic 

SELECT Customer_Name, Visit_Month,   
       LEAD (Visit_Month, 1, 'NONE') OVER (PARTITION BY Customer_Name ORDER BY Visit_Month DESC) AS Next_Order_Month  
FROM Visit_Logs_Basic  

-------------------------
-- yýl ve ay ikilileri için sýra numaralarý verdirdim (12.aydan sonra gelen aylarý 13,14... diye sýralayacak) 
-- müþterileri bir sonraki adýmda gruplayacaðým.
CREATE VIEW NEXT_VISIT AS
SELECT *,
		LEAD(CURRENT_MONTH, 1) OVER (PARTITION BY Cust_ID ORDER BY CURRENT_MONTH) NEXT_VISIT_MONTH
FROM
(
SELECT  *,
		DENSE_RANK () OVER (ORDER BY [YEAR] , [MONTH]) CURRENT_MONTH
		
FROM	NUMBER_OF_VISITS
) A

SELECT *
FROM NEXT_VISIT

--- 4. Calculate the monthly time gap between two consecutive visits by each customer.

CREATE VIEW Time_Gaps AS
SELECT *,
		NEXT_VISIT_MONTH - CURRENT_MONTH Time_Gaps
FROM	NEXT_VISIT


SELECT *
FROM Time_Gaps

--- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.

SELECT * FROM Time_Gaps
-- alýþveriþ tarihlerinden bir sonraki alýþveriþ tarihlerini yan yana getirip aralarýndaki farklarý aldým

SELECT Cust_ID, AVG(Time_Gaps) Avg_Time_Gap
FROM Time_Gaps
GROUP BY Cust_ID
-- burada da her müþterinin alýþveriþleri arasýnda geçen ortalama zamanlarý getirdim.
	-- buna göre artýk müþterilerin alýþveriþ yapma sýklýklarýný görebiliyorum.

SELECT Cust_ID, Avg_Time_Gap,
		CASE WHEN Avg_Time_Gap = 1 THEN 'retained'
			WHEN Avg_Time_Gap > 1 THEN 'irregular'
			WHEN Avg_Time_Gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN DATA' END CUST_LABELS
FROM
		(
		SELECT Cust_ID, AVG(Time_Gaps) Avg_Time_Gap
		FROM	Time_Gaps
		GROUP BY Cust_ID
		) A
-- müþterilerin alýþveriþleri arasýnda geçen ortalama zamanlara göre sýnýflandýrma yapmýþ oldum.
-- Örneðin ortalama 1 olan yani her ay alýþveriþ yapan retained (tutulan) müþteri yaptým.

Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month


/* MONTH-WÝSE RETENTÝON RATE
  Find month-by-month customer retention rate  since the start of the business.*/

--1. Find the number of customers retained month-wise. (You can use time gaps)

SELECT DISTINCT [YEAR],
				[MONTH],
				CURRENT_MONTH,
				NEXT_VISIT_MONTH,
				COUNT(Cust_ID) OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTION_MONTH_WISE
FROM			Time_Gaps
ORDER BY		NEXT_VISIT_MONTH


SELECT	DISTINCT Cust_ID, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		Time_Gaps,
		COUNT (Cust_ID)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	Time_Gaps
where	Time_Gaps =1
ORDER BY Cust_ID, NEXT_VISIT_MONTH

--Önceki aylarda alýþveriþi olmayan müþterileri bulup onlarý kazanmak istiyorum.


--- 2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month
--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View.
--You can also use CTE or Subquery if you want.
--You should pay attention to the join type and join columns between your views or tables.

CREATE VIEW CURRENT_NUM_OF_CUST AS
SELECT	DISTINCT Cust_ID, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		COUNT (Cust_ID)	OVER (PARTITION BY CURRENT_MONTH) RETENTITON_MONTH_WISE
FROM	Time_Gaps

SELECT *
FROM	CURRENT_NUM_OF_CUST

-------------------------------------

DROP VIEW NEXT_NUM_OF_CUST
CREATE VIEW NEXT_NUM_OF_CUST AS
SELECT	DISTINCT Cust_ID, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (Cust_ID)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	Time_Gaps
WHERE	Time_Gaps = 1
AND		CURRENT_MONTH > 1
--//////--
SELECT DISTINCT
		B.[YEAR],
		B.[MONTH],
		B.CURRENT_MONTH,
		B.NEXT_VISIT_MONTH,
		1.0 * B.RETENTITON_MONTH_WISE / A.RETENTITON_MONTH_WISE RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH


--END-- TAKE A REST!