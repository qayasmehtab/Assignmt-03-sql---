use bikestores

--Q1

SELECT TOP 10
	first_name AS full_name,
	last_name,
	email,
	city
FROM 
	sales.customers
WHERE
	state = 'NY'
	AND phone IS NULL 
ORDER BY 
 last_name DESC, full_name;

--Q2

SELECT 
	product_id,
	product_name,
	model_year,
	list_price
FROM 
	production.products
WHERE 
	model_year IN (2017,2018)
	AND list_price BETWEEN  500 AND  1500
	AND product_name LIKE '%trek%'
	AND product_name NOT LIKE '%kids%'
ORDER BY 
	list_price DESC;



--Q3
A

SELECT DISTINCT 
	order_status
FROM 
sales.orders

B

SELECT 
	order_id,
	customer_id,
	store_id, 
	order_date,
	required_date
FROM 
	sales.orders
WHERE
	shipped_date is NULL 
	AND store_id IN (1,3)
	AND year (order_date)  = 2018
ORDER BY 
	order_date ASC;

--Q4

SELECT
	o.order_id,
	o.order_date,
	CONCAT(c.first_name, '  ' ,c.last_name )AS customer_full_name,
	p.product_name,
	b.brand_name,
	cat.category_name, 
	oi.quantity, 
	oi.list_price, 
	oi.discount, 
	CAST(oi.quantity * oi.list_price * (1 - oi.discount) AS DECIMAL(12, 2)) AS line_revenue
FROM 
	sales.orders AS o
inner join
	sales.order_items AS oi
	on o.order_id = oi.order_id
inner join 
	sales.customers AS c 
	on o.customer_id = c.customer_id
inner join
	production.products AS P 
	on oi.product_id = p.product_id
inner join
	production.brands AS b
	on p.brand_id = b.brand_id
inner join
	production.categories AS cat 
	on cat.category_id = p.category_id
where 
	o.order_id = 1
ORDER BY 
	oi.item_id;

--Q5
SELECT 
	st.store_name,
	CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
	CASE WHEN m.staff_id IS NULL THEN 'No Manager' ELSE 
	CONCAT(m.first_name, ' ', m.last_name) END AS manager_name
FROM 
	sales.staffs AS s
LEFT JOIN
	sales.stores AS st 
	ON s.store_id = st.store_id
LEFT JOIN
	sales.staffs AS m 
	ON s.manager_id = m.staff_id
	
	
--Q6
	
SELECT 
	p.product_id,
	p.product_name,
	p.model_year,
	b.brand_name,
	oi.product_id
FROM 
	production.products AS p
inner JOIN 
	production.brands as b
	ON  p.brand_id = b.brand_id
LEFT JOIN sales.order_items AS oi
    ON p.product_id = oi.product_id
WHERE 
	oi.product_id IS NULL;
	
	
--Q7

-- (a)
CREATE VIEW sales.vw_order_line_details AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    st.store_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    CAST(oi.quantity * oi.list_price * (1 - oi.discount) AS DECIMAL(12, 2)) AS line_revenue
FROM 
	sales.orders AS o
INNER JOIN 
	sales.stores AS st
    ON o.store_id = st.store_id
INNER JOIN 
	sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN 
	sales.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN 
	production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN 
	production.brands AS b
    ON p.brand_id = b.brand_id
INNER JOIN
	production.categories AS cat
    ON p.category_id = cat.category_id;


-- (b)
SELECT *
FROM 
	sales.vw_order_line_details
WHERE 
	order_date >= '2018-01-01'
  	AND order_date < '2018-02-01'
ORDER BY 
	order_date, order_id;

	
--Q8

-- (a)
CREATE VIEW production.vw_product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    cat.category_name,
    p.model_year,
    p.list_price
FROM 
	production.products AS p
INNER JOIN
	production.brands AS b
    ON p.brand_id = b.brand_id
INNER JOIN 
	production.categories AS cat
    ON p.category_id = cat.category_id;

-- (b)
SELECT *
FROM 
	production.vw_product_catalog
WHERE 
	category_name = 'Electric Bikes'
  	AND list_price > 3000
ORDER BY
	list_price DESC;


--Q9
SELECT
    store_name,
    YEAR(order_date) AS order_year,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(line_revenue) AS total_revenue
FROM
	sales.vw_order_line_details
GROUP BY
	store_name, YEAR(order_date)
ORDER BY 
	store_name, order_year;

---Q10

SELECT
    b.brand_name,
    COUNT(p.product_id) AS product_count,
    MIN(p.list_price) AS min_price,
    CAST(AVG(p.list_price) AS DECIMAL(12, 2)) AS avg_price,
    MAX(p.list_price) AS max_price
FROM 
	production.brands AS b
INNER JOIN
	production.products AS p
    ON b.brand_id = p.brand_id
GROUP BY
	b.brand_name
HAVING 
	COUNT(p.product_id) > 10
ORDER BY
	avg_price DESC;


--Q11

SELECT
    p.product_name,
    cat.category_name,
    p.list_price,
    CAST(cat_avg.avg_category_price AS DECIMAL(12, 2)) AS avg_category_price
FROM 
	production.products AS p
INNER JOIN 
	production.categories AS cat
    ON p.category_id = cat.category_id
INNER JOIN(
SELECT
        category_id,
        AVG(list_price) AS avg_category_price
    FROM 
    	production.products
    GROUP BY 
    	category_id
) AS cat_avg
    ON p.category_id = cat_avg.category_id
WHERE
	p.list_price > cat_avg.avg_category_price;



--Q12


SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    state
FROM
	sales.customers
WHERE
	customer_id IN (
SELECT 
	customer_id
FROM 
	sales.orders
WHERE 
	YEAR(order_date) = 2016
     AND customer_id IS NOT NULL
)
  AND customer_id NOT IN (
SELECT
	customer_id
  FROM 
    sales.orders
 WHERE 
    YEAR(order_date) = 2018
    AND customer_id IS NOT NULL
);


--Q13

WITH StoreTotals AS (
SELECT
	st.store_name,
     SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM 
	sales.stores AS st
INNER JOIN
	sales.orders AS o
    ON st.store_id = o.store_id
INNER JOIN
	sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY st.store_name
),
AverageRevenue AS (
SELECT 
	AVG(total_revenue) AS avg_revenue
FROM
	StoreTotals
)
SELECT
    s.store_name,
    CAST(s.total_revenue AS DECIMAL(12, 2)) AS total_revenue,
    CAST(a.avg_revenue AS DECIMAL(12, 2)) AS average,
    CAST(s.total_revenue - a.avg_revenue AS DECIMAL(12, 2)) AS difference
FROM
	StoreTotals AS s
CROSS JOIN
	AverageRevenue AS a
WHERE
	s.total_revenue > a.avg_revenue;


--Q14

WITH StaffHierarchy AS (
SELECT
	staff_id,
    CONCAT(first_name, ' ', last_name) AS staff_full_name,
    manager_id,
    1 AS [level],
    CAST(CONCAT(first_name, ' ', last_name) AS VARCHAR(500)) AS reporting_path
FROM
	sales.staffs
WHERE
	manager_id IS NULL
UNION ALL
SELECT 
	s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_full_name,
    s.manager_id,
    sh.[level] + 1 AS [level],
    CAST(CONCAT(sh.reporting_path, ' > ', s.first_name, ' ', s.last_name) AS VARCHAR(500)) AS reporting_path
FROM 
	sales.staffs AS s
INNER JOIN
	StaffHierarchy AS sh
    ON s.manager_id = sh.staff_id
)
SELECT
    staff_id,
    staff_full_name,
    manager_id,
    [level],
    reporting_path
FROM 
	StaffHierarchy
ORDER BY
	[level], reporting_path;


---Q15


-- (a)
WITH ProductRevenue2017 AS (
 SELECT
 	cat.category_name,
    p.product_name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
    DENSE_RANK() OVER (
PARTITION BY 
	cat.category_name
ORDER BY
	SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
        ) AS revenue_rank
FROM
	sales.orders AS o
INNER JOIN 
	sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN 
	production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN 
	production.categories AS cat
    ON p.category_id = cat.category_id
WHERE 
	YEAR(o.order_date) = 2017
GROUP BY
	cat.category_name, p.product_name
)
SELECT
    category_name,
    product_name,
    total_quantity,
    CAST(total_revenue AS DECIMAL(12, 2)) AS total_revenue,
    revenue_rank
FROM
	ProductRevenue2017
WHERE
	revenue_rank <= 3
ORDER BY 
	category_name, revenue_rank;

-- (b)
WITH Months AS (
SELECT 
	1 AS month_num
UNION ALL
SELECT
	month_num + 
FROM
	Months
WHERE
	month_num < 12
),
Sales2017 AS (
SELECT
	MONTH(o.order_date) AS month_num,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM
	sales.orders AS o
INNER JOIN
	sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE
	YEAR(o.order_date) = 2017
GROUP BY
	MONTH(o.order_date)
)
SELECT
    m.month_num AS month_number,
    DATENAME(MONTH, DATEFROMPARTS(2017, m.month_num, 1)) AS month_name,
    ISNULL(s.total_orders, 0) AS total_orders,
    CAST(ISNULL(s.total_revenue, 0) AS DECIMAL(12, 2)) AS total_revenue
FROM
	Months AS m
LEFT JOIN 
	Sales2017 AS s
    ON m.month_num = s.month_num
ORDER BY
	m.month_num;







