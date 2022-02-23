CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
CREATE VIEW rorder AS 
SELECT 
r.order_id ,r.runner_id ,
CASE 
WHEN pickup_time= 'null' THEN NULL
ELSE pickup_time
END AS pickup_time,
CASE 
WHEN distance= 'null' THEN NULL
ELSE distance
END AS distance,
CASE 
	WHEN duration = '' THEN NULL
WHEN duration = 'null' THEN NULL
ELSE duration
END AS duration,
CASE 
	WHEN duration = '' THEN NULL
WHEN duration = 'null' THEN NULL
ELSE duration
END AS duration,
CASE 
	WHEN cancellation = '' THEN NULL
WHEN cancellation= 'null' THEN NULL
ELSE cancellation
END AS cancellation
FROM 
pizza_runner.runner_orders r;
select * from rorder;


CREATE VIEW custorder AS
SELECT 
c.order_id ,c.customer_id , c.pizza_id, 
CASE 
	WHEN exclusions= '' THEN NULL
WHEN exclusions = 'null' THEN NULL
ELSE exclusions 
END AS exclusions,
CASE 
	WHEN extras= '' THEN NULL
WHEN extras = 'null' THEN NULL
ELSE extras
END AS extras,
order_time
FROM 
pizza_runner.customer_orders as c;
select * from custorder









--                                A Pizza Metrics

-- How many pizzas were ordered?

SELECT COUNT(*) AS pizza_order_count
FROM pizza_runner.customer_orders;

-- How many unique customer orders were made?
 
SELECT COUNT(DISTINCT order_id) AS unique_order
FROM pizza_runner.customer_orders;


-- How many successful orders were delivered by each runner?
 
SELECT runner_id , COUNT(order_id)
 FROM pizza_runner.runner_orders
 WHERE pickup_time != 'null' 
 GROUP BY runner_id ORDER BY runner_id;
 
-- How many of each type of pizza was delivered?

SELECT p.pizza_name , count(c.pizza_id) AS total_delievered FROM pizza_runner.customer_orders AS c 
JOIN pizza_runner.runner_orders as r ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p ON c.pizza_id= p.pizza_id
WHERE r.pickup_time != 'null' GROUP BY p.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name , count(p.pizza_name) AS total_pizza
 FROM pizza_runner.customer_orders AS c 
JOIN pizza_runner.pizza_names AS p 
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id , p.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
SELECT MAX(c.pizza_perorder) AS max_order FROM (SELECT c.order_id , COUNT (c.order_id ) AS pizza_perorder
											 FROM pizza_runner.customer_orders1 AS c
											 JOIN pizza_runner.runner_orders1 AS r 
											 ON c.order_id = r.order_id
											 WHERE r.distance::DEC != 0
											 GROUP BY c.order_id
											 ORDER BY c.order_id) c

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
 				SUM(CASE 
 					WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1
  						ELSE 0
  						END) AS atleast1change,
 				SUM(CASE 
  					WHEN c.exclusions IS NULL AND c.extras  IS NULL THEN 1 
  					ELSE 0
  					END) AS nochange
FROM cusorder AS c
JOIN  rorder AS r
ON c.order_id = r.order_id
WHERE r.distance :: DEC != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;


-- How many pizzas were delivered that had both exclusions and extras?

SELECT  
 SUM(CASE
  WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
  ELSE 0
  END) AS pizzacount_and_exclusionsextras
FROM cusorder AS c
JOIN rorder AS r
 ON c.order_id = r.order_id
WHERE r.distance :: DEC != 0

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT  date_part('hour' , order_time) AS each_hr_day , 
COUNT(order_id) AS total_volume FROM cusorder
GROUP BY date_part('hour', order_time);

-- What was the volume of orders for each day of the week?
SELECT  date_part('day' , order_time) AS each_day_week , 
COUNT(order_id) AS total_volume  from cusorder
GROUP BY date_part('day', order_time);

--                           B. Runner and Customer Experience

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT date_part('week' ,registration_date) AS regweek ,
COUNT(runner_id) AS runner_signup 
FROM pizza_runner.runners
GROUP BY date_part('w' ,registration_date),runners.registration_date;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ 
-- to pickup the order?

WITH time_taken AS
(
 SELECT c.order_id, c.order_time, r.pickup_time, 
  DATE_PART('minute' , r.pickup_time ::timestamp - c.order_time::timestamp ) AS pickup_min
 FROM cusorder AS c
 JOIN rorder AS r
  ON c.order_id = r.order_id
 WHERE r.distance:: DEC!= 0
 GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT ROUND(AVG(pickup_min)) AS avg_pickup_min
FROM time_taken;

-- What was the average distance travelled for each customer?
SELECT c.customer_id , ROUND(AVG(r.distance::DEC)) 
FROM cusorder AS c
JOIN rorder AS r ON c.order_id = r.order_id
GROUP BY c.customer_id 
ORDER BY c.customer_id ;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT order_id , duration FROM pizza_runner.runner_orders 
-- WHERE duration IS NOT NULL
-- GROUP BY order_id , duration 
-- ORDER BY order_id;
SELECT 
    MAX(duration ::INT) - MIN(duration :: INT ) AS delivery_time_difference
FROM pizza_runner.runner_orders 
WHERE duration <> 'null'
-- SELECT * FROM pizza_runner.runner_orders ;
-- UPDATE pizza_runner.runner_orders 
-- SET duration = REPLACE(duration , 'mins' , '')
-- WHERE duration LIKE '%mins';
-- UPDATE pizza_runner.runner_orders 
-- SET duration = REPLACE(duration , 'utes' , '')
-- WHERE order_id = 1;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT r.runner_id, c.customer_id, c.order_id, 
 COUNT(c.order_id) AS pizza_count, 
 r.distance,
 ROUND((r.distance::DEC/ r.duration ::INT* 60), 2) AS avg_speed
FROM rorder AS r
JOIN custorder AS c
 ON r.order_id = c.order_id
WHERE distance::DEC != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;

-- What is the successful delivery percentage for each runner?
WITH deliver AS(
SELECT runner_id,
COUNT(order_id) AS total_orders,
SUM(
CASE
WHEN cancellation IS NOT NULL THEN 0
ELSE 1
END
) AS delivered_orders
FROM rorder
GROUP BY runner_id
)
SELECT runner_id,
ROUND(100*delivered_orders/(total_orders),2) AS successful_order_percentage
FROM deliver
ORDER BY runner_id



--          C. Ingredient Optimisation

CREATE TABLE pizza_recipes1 
(
 pizza_id int,
    toppings int);
INSERT INTO pizza_recipes1
(pizza_id, toppings) 
VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);
-- select * from pizza_recipes1;

WITH c AS (
SELECT n.pizza_name,p.pizza_id, t.topping_name
FROM pizza_recipes1 AS p
JOIN pizza_runner.pizza_toppings AS t
ON p.toppings = t.topping_id
JOIN pizza_runner.pizza_names AS n
ON n.pizza_id = p.pizza_id
ORDER BY  n.pizza_name, p.pizza_id)

SELECT c.pizza_id, string_agg(c.topping_name, ' , ')AS Standard_Toppings
FROM c
GROUP BY c.pizza_id
ORDER BY c.pizza_id;


-- What was the most commonly added extra?
SELECT p.topping_name FROM pizza_runner.pizza_toppings p 
WHERE topping_id= 
(SELECT regexp_split_to_table(extras,',')::int AS string 
 FROM customer_orders1 WHERE  extras != '' AND extras IS NOT null
 GROUP BY regexp_split_to_table(extras,',')::int 
 ORDER BY COUNT(*) DESC LIMIT 1); 
 
-- What was the most common exclusion?
SEELCT p.topping_name FROM pizza_runner.pizza_toppings p
WHERE topping_id= 
(SELECT regexp_split_to_table(exclusions,',')::int AS string 
 FROM customer_orders1 WHERE  exclusions != '' AND exclusions IS NOT null
 GROUP BY  regexp_split_to_table(exclusions,',')::int 
 ORDER BY COUNT(*) DESC LIMIT 1); 
 
 
-- Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT c.order_id, c.pizza_id, n.pizza_name, c.exclusions, c.extras, 
CASE
when c.pizza_id = 1 and (exclusions is null) and (extras is null) then 'Meat Lovers'
when c.pizza_id = 2 and (exclusions is null) and (extras is null) then 'Veg Lovers'
when c.pizza_id = 2 and (exclusions = '4') and (extras is null) then 'Veg Lovers - Exclude Cheese'
when c.pizza_id = 1 and (exclusions = '4' ) and (extras is null) then 'Meat Lovers - Exclude Cheese'
when c.pizza_id= 1 and (exclusions = '3') and (extras is null) then 'Meat Lovers - Exclude Beef'
when c.pizza_id =1 and (exclusions is null) and (extras ='1') then 'Meat Lovers - Extra Bacon'
when c.pizza_id=1 and (exclusions like '1, 4' ) and (extras like '6, 9') then 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
when c.pizza_id=1 and (exclusions like '2, 6' ) and (extras like '1, 4') then 'Meat Lovers - Exclude BBQ Sauce,Mushroom - Extra Bacon, Cheese'
when c.pizza_id=1 and (exclusions = '4') and (extras like '1, 5') then 'Meat Lovers - Exclude Cheese - Extra Bacon, Chicken'
end AS OrderItem
FROM custorder AS c
JOIN pizza_runner.pizza_names AS n
ON n.pizza_id = c.pizza_id
ORDER BY c.order_id;
-- select * from custorder
 
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
SELECT * , CASE 
when c.pizza_id = 1 and (exclusions is null) and (extras is null) then 'Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id = 2 and (exclusions is null) and (extras is null) then 'Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id = 2 and (exclusions = '4') and (extras is null) then 'Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id = 1 and (exclusions = '4' ) and (extras is null) then 'Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id= 1 and (exclusions = '3') and (extras is null) then 'Bacon,BBQ Sauce,Cheese,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id =1 and (exclusions is null) and (extras ='1') then '2xBacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id=1 and (exclusions like '1, 4' ) and (extras like '6, 9') then 'BBQ Sauce,Beef,Chicken,2xMushrooms,Onions,Pepperoni,2xPeppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id=1 and (exclusions like '2, 6' ) and (extras like '1, 4') then '2xBacon,Beef,2xCheese,Chicken,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
when c.pizza_id=1 and (exclusions = '4') and (extras like '1, 5') then '2xBacon,BBQ Sauce,Beef,2xChicken,Mushrooms,Onions,Pepperoni,Peppers,Salami,Tomatoes,Tomato Sauce'
end AS o
FROM custorder AS c

-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



--                                D. Pricing and Ratings
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges 
-- for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(case 
when c.pizza_id = 1 then 12
else 10
end) AS Total_Amount
FROM rorder r
JOIN custorder AS c
ON c.order_id = r.order_id
WHERE r.distance IS NOT null;


-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
select * from custorder
with CTE AS(SELECT *, 
    CASE 
			WHEN EXTRAS IS NOT NULL AND EXTRAS != '' 
            THEN (LENGTH(EXTRAS) - LENGTH(REPLACE(EXTRAS,',','')) + 1)  
        	ELSE 0 
    	END total_extras 
			FROM custorder) 

SELECT customer_id,order_id,pizza_id,total_extras, 
  SUM(CASE 
        WHEN pizza_id=1 AND total_extras > 0 then 12+total_extras 
        WHEN pizza_id=2 AND total_extras > 0  then 10+total_extras 
		WHEN pizza_id=1 AND total_extras = 0 then 12
	  	ELSE 10 
		END)Total_Amount 
FROM CTE 
GROUP BY customer_id,order_id,pizza_id,total_extras 
ORDER BY order_id; 

 

-- The Pizza Runner team now wants to add an additional ratings system that
-- allows customers to rate their runner, how would you design an additional table for
-- this new dataset - generate a schema for this new table and insert your own data for
-- ratings for each successful customer order between 1 to 5.

create table ratings (
order_id integer,
rating integer);
insert into ratings
(order_id, rating)
values
(1,3),
(2,5),
(3,2),
(4,1),
(5,5),
(7,3),
(8,4),
(10,2);
-- select * from ratings


-- Using your newly generated table - can you join all of the information together to 
-- form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

SELECT c.customer_id, c.order_id, r.runner_id, a.rating, c.order_time,
r.pickup_time, DATE_PART('minute' , r.pickup_time ::timestamp - c.order_time::timestamp ) AS TimebwOrderandPickup,
r.duration, ROUND (AVG(r.distance :: DEC/r.duration :: INT*60),1) as avgspeed, count(c.pizza_id) as PizzaCount
FROM custorder AS c
JOIN rorder AS r
on c.order_id = r.order_id
JOIN ratings AS a
ON a.order_id = c.order_id
group by c.customer_id, c.order_id, r.runner_id, a.rating, c.order_time,
r.pickup_time, TimebwOrderandPickup, r.duration
order by customer_id;


-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
-- each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have
-- left over after these deliveries?
SELECT SUM(case 
when c.pizza_id = 1 then 12
else 10
end) - SUM(r.distance::DEC)*.30 
FROM rorder r
JOIN custorder AS c
ON c.order_id = r.order_id
WHERE r.distance IS NOT null;


 