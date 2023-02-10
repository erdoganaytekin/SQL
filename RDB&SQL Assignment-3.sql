--- RDB&SQL Assignment-3 (DS 13/22 EU)

/* Discount Effects 

Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. 

Sample Result:
Product_id	Discount Effect
1	Positive
2	Negative
3	Negative
4	Neutral 
*/

WITH discount_order_count AS (
SELECT product_id, discount, COUNT(DISTINCT order_id) as order_count
FROM sale.order_item
GROUP BY product_id, discount
),
order_count_difference AS (
SELECT product_id, discount, order_count,
LAG(order_count) OVER (PARTITION BY product_id ORDER BY discount) - order_count as order_count_difference
FROM discount_order_count
)
SELECT DISTINCT product_id, discount,
CASE
WHEN order_count_difference > 0 THEN 'Positive'
WHEN order_count_difference < 0 THEN 'Negative'
ELSE 'Neutral'
END as 'Discount Effect'
FROM order_count_difference
ORDER BY product_id, discount;
