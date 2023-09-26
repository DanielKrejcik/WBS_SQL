USE magist;
SELECT count(products.product_id), count(order_items.product_id), avg(price)
FROM products
INNER JOIN product_category_name_translation
ON product_category_name_translation.product_category_name=products.product_category_name
INNER JOIN order_items
ON products.product_id = order_items.product_id
GROUP BY product_category_name_english
HAVING product_category_name_english = "computers_accessories" 
	OR product_category_name_english = "telephony" 
	OR product_category_name_english = "electronics" 
    OR product_category_name_english = "audio" 
    OR product_category_name_english = "computers"
    OR product_category_name_english = "pc gamer"
ORDER BY count(product_id) DESC;

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

select * from order_items ORDER BY price DESC;
select count(DISTINCT order_id) from order_items;
select count(DISTINCT order_id) from orders; -- 

select count(order_id) from order_items;
select count( order_id) from orders;        