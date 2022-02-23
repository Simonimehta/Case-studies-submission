CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- 						CASE STUDY 1 DANNYS_DINER

-- What is the total amount each customer spent at the restaurant?
SELECT dannys_diner.sales.customer_id ,SUM(price)AS Total_sum_eachcustomer
FROM dannys_diner.menu INNER JOIN
dannys_diner.sales ON dannys_diner.menu.product_id = dannys_diner.sales.product_id
GROUP BY customer_id;	
	

-- How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(DISTINCT order_date) AS totalnum_each_customer_order 
FROM dannys_diner.sales GROUP BY customer_id 
ORDER BY customer_id ASC;
	
-- What was the first item from the menu purchased by each customer?
SELECT DISTINCT(customer_id),  product_name
FROM dannys_diner.sales s 
JOIN dannys_diner.menu m ON m.product_id = s.product_id 
WHERE s.order_date = ANY  
(SELECT MIN(order_date) FROM dannys_diner.sales  
GROUP BY customer_id );

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT B.product_name, COUNT(*) FROM dannys_diner.sales AS A 
INNER JOIN dannys_diner.menu AS B ON A.product_id = B.product_id 
GROUP BY  B.product_name 
ORDER BY COUNT(*) DESC LIMIT 1;
 
-- Which item was the most popular for each customer?
WITH c AS
(
SELECT s.customer_id,m.product_name,
COUNT(s.product_id) AS count,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS r
FROM dannys_diner.menu m
JOIN dannys_diner.sales s
ON s.product_id = m.product_id
GROUP BY s.customer_id, s.product_id, m.product_name
)
SELECT customer_id, product_name, count FROM c
WHERE r = 1

-- Which item was purchased first by the customer after they became a member?
SELECT g.customer_id, g.order_date, a.product_name 
FROM
(
SELECT k.customer_id, m.join_date, k.order_date,   k.product_id,
DENSE_RANK() OVER(PARTITION BY k.customer_id
ORDER BY k.order_date) AS rank
FROM dannys_diner.sales  AS k
JOIN dannys_diner.members AS m
ON k.customer_id = m.customer_id
WHERE k.order_date >= m.join_date
)g JOIN dannys_diner.menu AS a
ON g.product_id = a.product_id
WHERE rank = 1;

-- Which item was purchased just before the customer became a member?
SELECT g.customer_id, g.order_date, a.product_name 
FROM
(
SELECT k.customer_id, m.join_date, k.order_date,  k.product_id,
DENSE_RANK() OVER(PARTITION BY k.customer_id
ORDER BY k.order_date DESC) AS rank
FROM dannys_diner.sales  AS k
JOIN dannys_diner.members AS m
ON k.customer_id = m.customer_id
WHERE k.order_date < m.join_date
) g JOIN dannys_diner.menu AS a
ON g.product_id = a.product_id
WHERE rank = 1;

-- What is the total items and amount spent for each member before they became a member?
SELECT C.customer_id ,COUNT(*), SUM(C.price) 
FROM (dannys_diner.sales s INNER JOIN
dannys_diner.menu  m ON m.product_id = s.product_id) C 
INNER JOIN dannys_diner.members g ON C.customer_id = g.customer_id 
WHERE C.order_date < g.join_date GROUP BY  C.customer_id ;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, 10 * SUM(p.points) AS total_points FROM
 (
SELECT *, 
CASE
 WHEN product_name = 'sushi' THEN price * 2
 ELSE price 
 END AS points
 FROM dannys_diner.menu
 ) p
JOIN dannys_diner.sales AS s
ON p.product_id = s.product_id
GROUP BY s.customer_id order by s.customer_id

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


