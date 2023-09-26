USE magist;

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
    
    
    
select distinct state from geo;

select product_weight_g from products order by product_weight_g DESC;
select count(zip_code_prefix) from geo;
select count(distinct customer_zip_code_prefix) from customers;
timeorder_estimated_delivery_date
order_delivered_customer_date