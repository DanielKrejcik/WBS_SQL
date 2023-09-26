use magist;
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
		sum(price) AS earnings, 
        sum(price)/count(DISTINCT seller_id) AS average_earnings_per_techseller,
        (sum(price)/count(DISTINCT seller_id))/(SELECT timestampdiff(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders) AS monthly_average
FROM 	order_items oi
RIGHT JOIN products p
	ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation trans
	ON trans.product_category_name=p.product_category_name
WHERE 	product_category_name_english in ("computers_accessories", "telephony", "electronics", "audio", "computers", "pc gamer");