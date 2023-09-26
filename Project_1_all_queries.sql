use magist;
-- introduction queries for getting into the datatset:
-- question 1:
SELECT count(order_id)
FROM orders; -- 99.441 total
-- sample solution
-- SELECT 
   -- COUNT(*) AS orders_count
-- FROM
   -- orders;
   
-- question 2:
SELECT 	count(order_id),
		order_status
FROM 	orders
GROUP BY order_status; -- 96.478 delivered, 609 unavailbale, 1107 shipped, 625 canceled, 314 invoiced, 301 processing, 2 approved, 5 created

-- question 3:
SELECT count(order_id), MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp)
FROM orders
GROUP BY MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp); -- September/October 2018 alarmingly underperforming - from 6k orders a month down to double and even single-digit

-- sample solution:
SELECT count(customer_id), MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp)
FROM orders
GROUP BY MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp);

-- question 4:
SELECT count(product_id)
FROM products; -- 32951 product ids assigned
SELECT count(DISTINCT product_id)
FROM products;

-- question 5:
SELECT count(product_id), product_category_name_english
FROM products
INNER JOIN product_category_name_translation
ON product_category_name_translation.product_category_name=products.product_category_name
GROUP BY product_category_name_english
-- HAVING product_category_name_english = "computers_accessories" OR product_category_name_english = "telephony" OR product_category_name_english = "electronics"
-- maybe: office furniture, audio, computers, pc gamer
ORDER BY count(product_id) DESC; -- category 'informatica_acessorios' contains 1639 separate product ids, another 1134 in 'telefonica', 789 in 'cool stuff' and 517 in 'electronicos', 30 in 'pcs', 317 in 'consoles_games'

-- question 6:
SELECT count(DISTINCT product_id) FROM order_items;

-- question 7:
SELECT max(price), product_id
FROM order_items
GROUP BY product_id
ORDER BY max(price) DESC
LIMIT 1; -- most expansive item costs 6735 real
SELECT min(price), product_id
FROM order_items
GROUP BY product_id
ORDER BY min(price)
LIMIT 1; -- cheapest item costs 0.85 real

-- question 8:
SELECT max(payment_value), order_id
FROM order_payments
GROUP BY order_id
ORDER BY max(payment_value) DESC
LIMIT 1; -- biggest order is 13.664.1 real
SELECT min(payment_value), order_id
FROM order_payments
GROUP BY order_id
ORDER BY min(payment_value)
LIMIT 10; -- smallest order has been free of charge (8 times, some 0.01 real as well) needs further insight to identify reasons (prices, refunds etc pp)

-- what timeframe is covered by the DB? 772 days
select timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders;

-- how many sellers? 3095
select count(DISTINCT seller_id) from sellers;

-- how mnay tech sellers?
select count(DISTINCT s.seller_id), product_category_name_english  from sellers s
right join order_items oi on s.seller_id=oi.seller_id
right join products p on oi.product_id=p.product_id
right join product_category_name_translation trans ON trans.product_category_name=p.product_category_name
GROUP BY product_category_name_english
HAVING product_category_name_english = "computers_accessories" -- 287 
	OR product_category_name_english = "telephony" -- 149
	OR product_category_name_english = "electronics" -- 149
    OR product_category_name_english = "audio" -- 36
    OR product_category_name_english = "computers" -- 9
    OR product_category_name_english = "pc gamer"; -- 630/3095 = 20.36% = share of techsellers

-- total earnings?
SELECT sum(payment_value) from order_payments; -- 16.008.872,14
select sum(price) from order_items; -- 13.591.643,70
select sum(freight_value) from order_items; -- 2.251.909,54


-- total earnings by tech sellers?
select product_category_name_english AS category, format(sum(price),2) AS earnings, format((sum(price)/(SELECT sum(price) FROM order_items)*100),2) AS percentage from order_items oi
right join products p on oi.product_id=p.product_id
right join product_category_name_translation trans ON trans.product_category_name=p.product_category_name
GROUP BY product_category_name_english WITH ROLLUP
HAVING product_category_name_english = "computers_accessories" -- 911.954,32 earnings per category
	OR product_category_name_english = "telephony" -- 323.667,53
	OR product_category_name_english = "electronics" -- 160.246,74
    OR product_category_name_english = "audio" -- 50.688,50
    OR product_category_name_english = "computers"; -- 222.963,13


-- average monthly earnings per seller?
SELECT (sum(price)/count(DISTINCT seller_id))/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders) from order_items;

-- average monthly earnings per techseller? 
SELECT  
		product_category_name_english,
		sum(price) AS earnings, 
        sum(price)/count(DISTINCT seller_id) AS average_earnings_per_techseller,
        (sum(price)/count(DISTINCT seller_id))/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders) AS monthly_average
FROM 	order_items oi
RIGHT JOIN products p
	ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation trans
	ON trans.product_category_name=p.product_category_name
GROUP BY product_category_name_english
HAVING product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");

USE magist;
SELECT count(DISTINCT order_items.product_id), avg(price), product_category_name_english
FROM products
INNER JOIN product_category_name_translation
ON product_category_name_translation.product_category_name=products.product_category_name
RIGHT JOIN order_items
ON products.product_id = order_items.product_id
GROUP BY product_category_name_english
HAVING product_category_name_english = "computers_accessories" 
	OR product_category_name_english = "telephony" 
	OR product_category_name_english = "electronics" 
    OR product_category_name_english = "audio" 
    OR product_category_name_english = "computers"
    OR product_category_name_english = "pc gamer"
ORDER BY count(products.product_id) DESC;

select sum(price) from order_items;

SELECT count(order_id) AS totaltechorders, count(DISTINCT order_id) AS crosssaleorders, product_category_name_english AS category, avg(price)-- /count(order_item_id) AS priceperpiece
FROM products
INNER JOIN product_category_name_translation
ON product_category_name_translation.product_category_name=products.product_category_name
RIGHT JOIN order_items
ON order_items.product_id = products.product_id
GROUP BY product_category_name_english-- , order_item_id
HAVING (product_category_name_english = "computers_accessories" 
	OR product_category_name_english = "telephony" 
	OR product_category_name_english = "electronics" 
    OR product_category_name_english = "audio" 
    OR product_category_name_english = "computers"
    OR product_category_name_english = "pc gamer")
    -- AND order_item_id > 1
ORDER BY count(order_items.product_id) DESC;

select count(DISTINCT product_id) from order_items;
select count(DISTINCT product_id) from products;

SELECT count(oi.product_id), product_category_name_english, format(sum(price),2) AS orders_volume,
CASE WHEN price > 2000 then '2000+ €'
		WHEN price between 1500 and 2000 then '1500+ €'
        WHEN price between 1000 and 1500 then '1000+ €'
        WHEN price between 500 and 1000 then '500+ €'
        WHEN price between 200 and 500 then '200+ €'
        WHEN price between 100 and 200 then '100+ €'
        ELSE 'below 100 €'
        END AS pricelevel
FROM order_items oi
RIGHT JOIN products p 
	ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation trans
	ON trans.product_category_name=p.product_category_name 
GROUP BY product_category_name_english , pricelevel WITH ROLLUP
HAVING product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");

SELECT count(oi.product_id), product_category_name_english, format(sum(price),2) AS orders_volume,
CASE WHEN price > 5000 then '5000+ €'
        WHEN price between 4000 and 5000 then '4000+ €'
        WHEN price between 3000 and 4000 then '3000+ €'
        WHEN price between 2000 and 3000 then '2000+ €'
        WHEN price between 1000 and 2000 then '1000+ €'
        WHEN price between 500 and 1000 then '500+ €'
        WHEN price between 200 and 500 then '200+ €'
        ELSE 'not our business'
        END AS pricelevel
FROM order_items oi
RIGHT JOIN products p 
    ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation trans
    ON trans.product_category_name=p.product_category_name 
WHERE(product_category_name_english = "computers_accessories" 
    OR product_category_name_english = "telephony" 
    OR product_category_name_english = "electronics" 
    OR product_category_name_english = "audio" 
    OR product_category_name_english = "computers"
    OR product_category_name_english = "pc gamer")
    AND price >= 200
GROUP BY product_category_name_english, pricelevel  WITH ROLLUP
ORDER BY
    product_category_name_english;

USE magist;
SELECT count(DISTINCT order_items.product_id), product_category_name_english
FROM products
INNER JOIN product_category_name_translation
ON product_category_name_translation.product_category_name=products.product_category_name
RIGHT JOIN order_items
ON order_items.product_id = products.product_id
GROUP BY product_category_name_english, order_item_id
HAVING (product_category_name_english = "computers_accessories" 
	OR product_category_name_english = "telephony" 
	OR product_category_name_english = "electronics" 
    OR product_category_name_english = "audio" 
    OR product_category_name_english = "computers"
    OR product_category_name_english = "pc gamer")
    AND order_item_id > 1
ORDER BY count(order_items.product_id) DESC;

-- DELIVERIES
-- average delivery time?
SELECT
	avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)) AS average_delivery_time
FROM
	orders;
    
-- how many orders on time and how many orders delayed?
SELECT
	count(order_id),
CASE
	WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
	ELSE 'delayed'
    END AS delivery_date_check
FROM
	orders
GROUP BY
	delivery_date_check WITH ROLLUP;
    
-- is there a relation between item categories and delayed deliveries? HOW TO GET the percentage for the specific categories? Additionally, is there a way to 
SELECT
	count(o.order_id) AS number_of_orders, product_category_name_english AS category,
    (count(o.order_id)/(
		SELECT 
			count(o.order_id) 
		FROM
			orders o
		RIGHT JOIN
			order_items oi
		ON
			o.order_id=oi.order_id
		RIGHT JOIN
			products p
		ON
			oi.product_id=p.product_id
		INNER JOIN
			product_category_name_translation trans
		ON
			trans.product_category_name=p.product_category_name
		WHERE
			product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer")))*100 AS percentage,
CASE
	WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
	ELSE 'delayed'
    END AS delivery_date_check
FROM
	orders o
RIGHT JOIN
	order_items oi
ON
	o.order_id=oi.order_id
RIGHT JOIN
	products p
ON
	oi.product_id=p.product_id
INNER JOIN
	product_category_name_translation trans
ON
	trans.product_category_name=p.product_category_name
GROUP BY
	product_category_name_english, delivery_date_check
HAVING
	product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");	

-- relation between freight weight and delayed delivery?
SELECT
	count(o.order_id) AS number_of_orders,
CASE
	WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
	ELSE 'delayed'
    END AS delivery_date_check,
CASE
	WHEN product_weight_g > 19999 THEN 'VERY HEAVY 20kg+'
    WHEN product_weight_g BETWEEN 10000 AND 19999 THEN 'HEAVY 10kg+'
    WHEN product_weight_g BETWEEN 5000 AND 9999 THEN 'MEDIUM 5kg+'
    ELSE 'LIGHT <5kg'
    END AS weight_categories
FROM
	orders o
RIGHT JOIN
	order_items oi
ON
	o.order_id=oi.order_id
RIGHT JOIN
	products p
ON
	oi.product_id=p.product_id
GROUP BY
	delivery_date_check, weight_categories
ORDER BY
	weight_categories DESC;

-- delivery times influenced by region?
SELECT
	avg(timestampdiff(day, order_purchase_timestamp, order_estimated_delivery_date)) AS average_delivery_est,
    avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)) AS average_delivery_time,
CASE 
	WHEN state IN ('MA', 'PI', 'CE', 'RN', 'PB', 'PE', 'AL', 'SE', 'PA') THEN 'Nordeste / Northeast'
    WHEN state IN ('MG', 'ES', 'RJ', 'SP') THEN 'Sudeste / Southeast'
    WHEN state IN ('PR', 'SC', 'RS') THEN 'Sul / South'
    WHEN state = 'DF' THEN 'Distrito Federal / Federal District'
    ELSE 'inland'
    END AS region
FROM
	orders o
RIGHT JOIN
	customers c
ON
	o.customer_id = c.customer_id
INNER JOIN
	geo g
ON
	c.customer_zip_code_prefix = g.zip_code_prefix
GROUP BY 
	region;
    
-- delivery times per state?
SELECT
	avg(timestampdiff(day, order_purchase_timestamp, order_estimated_delivery_date)) AS average_delivery_est,
    avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)) AS average_delivery_time,
    state,
    count(DISTINCT o.order_id) AS number_of_orders,
    CASE
		WHEN product_weight_g > 19999 THEN 'VERY HEAVY 20kg+'
		WHEN product_weight_g BETWEEN 10000 AND 19999 THEN 'HEAVY 10kg+'
		WHEN product_weight_g BETWEEN 5000 AND 9999 THEN 'MEDIUM 5kg+'
		ELSE 'LIGHT <5kg'
		END AS weight_categories,
	CASE
		WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
		ELSE 'delayed'
		END AS delivery_date_check
FROM
	orders o
RIGHT JOIN
	order_items oi
ON
	o.order_id = oi.order_id
RIGHT JOIN
	products p
ON
	oi.product_id = p.product_id
RIGHT JOIN
	customers c
ON
	o.customer_id = c.customer_id
INNER JOIN
	geo g
ON
	c.customer_zip_code_prefix = g.zip_code_prefix
GROUP BY 
	state, weight_categories, delivery_date_check;

-- Delivery-delays by freight-weight and states
USE magist;
SELECT
	avg(timestampdiff(day, order_purchase_timestamp, order_estimated_delivery_date)) AS average_delivery_est,
    avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)) AS average_delivery_time,
    state,
    count(DISTINCT o.order_id) AS number_of_orders,
    product_category_name_english,
    CASE
		WHEN product_weight_g > 19999 THEN 'VERY HEAVY 20kg+'
		WHEN product_weight_g BETWEEN 10000 AND 19999 THEN 'HEAVY 10kg+'
		WHEN product_weight_g BETWEEN 5000 AND 9999 THEN 'MEDIUM 5kg+'
		ELSE 'LIGHT <5kg'
		END AS weight_categories,
	CASE
		WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
		ELSE 'delayed'
		END AS delivery_date_check,
 	CASE
	 	WHEN avg(timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date)) >= 1 
        THEN avg(timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date))
	 	ELSE 0
	 	END AS delivery_delay
FROM
	orders o
RIGHT JOIN
	order_items oi
ON
	o.order_id = oi.order_id
RIGHT JOIN
	products p
ON
	oi.product_id = p.product_id
INNER JOIN
	product_category_name_translation trans
ON
	trans.product_category_name=p.product_category_name
RIGHT JOIN
	customers c
ON
	o.customer_id = c.customer_id
INNER JOIN
	geo g
ON
	c.customer_zip_code_prefix = g.zip_code_prefix
GROUP BY
	state, weight_categories, delivery_date_check, product_category_name_english
HAVING
	product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");

-- Distinct seller analysis:
select 
	count(DISTINCT oi.seller_id),
	format((sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
	/count(DISTINCT oi.seller_id)),2) AS monthly_earning, 
    product_category_name_english,
case when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 50 then 'nano'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
	/count(DISTINCT oi.seller_id) < 100 then 'micro'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 150 then 'very small'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 200 then 'small'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 500 then 'medium'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 1000 then 'large'
else 'competetive'
end as seller_category
from sellers s
right join order_items oi on s.seller_id=oi.seller_id
right join products p on oi.product_id=p.product_id
inner join product_category_name_translation trans ON trans.product_category_name=p.product_category_name
GROUP BY product_category_name_english, seller_category
HAVING product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");

SELECT 
		DISTINCT seller_id,
        format((sum(price)/count(DISTINCT order_id)),2) as avg_revenue_per_sale,
        format(sum(price),2) as sellers_revenue,
        count(DISTINCT order_id) as sales_per_seller,
        product_category_name_english,
        format((sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
		/count(DISTINCT oi.seller_id)),2) AS monthly_revenue,
CASE WHEN count(DISTINCT order_id) > 250 then 'big player'
	WHEN count(DISTINCT order_id) > 150 then 'professional'
	WHEN count(DISTINCT order_id) > 50 then 'continously'
	WHEN count(DISTINCT order_id) > 30 then 'regular'
    WHEN count(DISTINCT order_id) > 20 then 'okay'
    WHEN count(DISTINCT order_id) > 10 then 'low'
    else 'conincidentally'
    end as sales_number,
case when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 50 then 'nano'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
	/count(DISTINCT oi.seller_id) < 100 then 'micro'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 150 then 'very small'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 200 then 'small'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 500 then 'medium'
when sum(price)/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders)
    /count(DISTINCT oi.seller_id) < 1000 then 'large'
else 'competetive'
end as monthly_revenue_group
FROM
		order_items oi
RIGHT JOIN
		products p on oi.product_id=p.product_id
inner join product_category_name_translation trans ON trans.product_category_name=p.product_category_name
GROUP BY product_category_name_english, seller_id
HAVING product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer")
ORDER BY monthly_revenue DESC;


select * from order_items ORDER BY price DESC;
select count(DISTINCT order_id) from order_items;
select count(DISTINCT order_id) from orders; -- 

select count(order_id) from order_items;
select count( order_id) from orders;        