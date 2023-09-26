USE magist;

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