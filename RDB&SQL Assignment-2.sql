	/*1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the product below or not.

	1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)

	To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.


	Desired Output:

	Customer_Id		First_Name		Last_Name		Other_Product
	17				Rima			Miller			No
	18				Parthenia		Lawrence		No
	31				Glory			Russell			No
	*/

select  a.customer_id,a.first_name,a.last_name,
  case
	when d.product_name = 'Polk Audio - 50 W Woofer - Black'
	Then 'Yes'
	else 'No'
  end as Other_Product
  from	sale.customer a
	left join sale.orders b on a.customer_id=b.customer_id
	left join sale.order_item c on b.order_id=c.order_id
	left join product.product d on c.product_id=d.product_id
where a.customer_id in
	(select a.customer_id
	from sale.customer a
	left join sale.orders b on a.customer_id=b.customer_id
	left join sale.order_item c on b.order_id=c.order_id
	left join product.product d on c.product_id=d.product_id
	where d.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	)

	/*2. Conversion Rate
Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements given by an E-Commerce company. 
Write a query to return the conversion and cancellation rates for each Advertisement type.
Actions:
Visitor_ID	Adv_Type	Action
1	A	Left
2	A	Order
3	B	Left
4	A	Order
5	A	Review
6	A	Left
7	B	Left
8	B	Order
9	B	Review
10	A	Review


Desired_Output:

Adv_Type	Conversion_Rate
A	0.33
B	0.25


*/
-- 1. a.	Create above table (Actions) and insert values

CREATE TABLE Actions 
(
Visitor_ID int,
Adv_Type VARCHAR(10),
Action_m VARCHAR(10),
);
	 INSERT INTO Actions (Visitor_ID, Adv_Type,Action_m)
 VALUES 
(1,'A','Left'),
(2,'A','Order'),
(3,'B','Left'),
(4,'A','Order'),
(5,'A','Review'),
(6,'A','Left'),
(7,'B','Left'),
(8,'B','Order'),
(9,'B','Review'),
(10,'A','Review');


--2. b.	Retrieve count of total Actions, and Orders for each Advertisement Type

SELECT Adv_Type, Count(Action_m) As Num_Action, (SELECT Count(Action_m) FROM Actions WHERE Action_m = 'Order' AND Adv_Type = 'A' ) As Num_order 
FROM Actions
WHERE Adv_Type = 'A'
GROUP BY Adv_Type

UNION 

SELECT Adv_Type, Count(Action_m) As Num_Action, (SELECT Count(Action_m) FROM Actions WHERE Action_m = 'Order' AND Adv_Type = 'B' ) As Num_order 
FROM Actions
WHERE Adv_Type = 'B'
GROUP BY Adv_Type

--3.Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.

SELECT Adv_Type, ROUND(CAST( Num_Order as float)/CAST (Num_Action as float), 2)  AS Conversion_Rate
FROM  (SELECT Adv_Type, Count(Action_m) As Num_Action, (SELECT Count(Action_m) FROM Actions WHERE Action_m = 'Order' AND Adv_Type = 'A' ) As Num_order 
FROM Actions
WHERE Adv_Type = 'A'
GROUP BY Adv_Type

UNION 

SELECT Adv_Type, Count(Action_m) As Num_Action, (SELECT Count(Action_m) FROM Actions WHERE Action_m = 'Order' AND Adv_Type = 'B' ) As Num_order 
FROM Actions
WHERE Adv_Type = 'B'
GROUP BY Adv_Type
) New_table

