-- 1. Total number os orders placed

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
 -- Ans - 21350
 
 -- 2. Calculate the total revenue genereated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- Ans. 817860.05


-- 3. Identify the highest prize pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Ans. 35.95

-- 4. Identify the most common pizza size ordered

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_count desc;
  
-- Ans. L	18526
-- M	15385
-- S	14137
-- XL	544
-- XXL	28

-- 5. List the top 5 most pizza types along with their quantitites

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- The Classic Deluxe Pizza	2453
-- The Barbecue Chicken Pizza	2432
-- The Hawaiian Pizza	2422
-- The Pepperoni Pizza	2418
-- The Thai Chicken Pizza	2371


-- 6. Join the necessary tables to find the total quantity orders of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY category DESC;

-- Ans 
-- Veggie	11649
-- Supreme	11987
-- Classic	14888
-- Chicken	11050

-- -- 7. Determine the distribution of orders by hour of the day

select hour(order_time) as hour, count(order_id) as total_orders from orders
group by hour(order_time);

--  Ans
-- 11	1231
-- 12	2520
-- 13	2455
-- 14	1472
-- 15	1468
-- 16	1920
-- 17	2336
-- 18	2399
-- 19	2009
-- 20	1642
-- 21	1198
-- 22	663
-- 23	28
-- 10	8
-- 9	1
 
 
 -- 8. Join the relevant tables to find the category wise distribution of pizzas

select category, count(name) from pizza_types
group by category;

-- Ans.
-- Chicken	6
-- Classic	8
-- Supreme	9
-- Veggie	9

select orders.order_date, sum(order_details.quantity)
from order_details join orders 
on orders.order_id - order_details.order_id
group by orders.order_date;


-- 9. Groups the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS Pizzas_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        order_details
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Ans. 138


-- 10. Determine the Top 3 most ordered pizzas based on revenue

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Ans. 
-- The Thai Chicken Pizza	43434.25
-- The Barbecue Chicken Pizza	42768
-- The California Chicken Pizza	41409.5


-- 11. Calculate the percentage distribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- Ans. 
-- Classic	26.91
-- Veggie	23.68
-- Supreme	25.46
-- Chicken	23.96


-- 12. Analyze the cumulative revenue gerenerated over time

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by orders.order_date ) as sales;


-- 13. Determine the Top 3 most ordered pizza types based on revenue foe each pizza type category

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category, pizza_types.name,
sum(pizzas.price * order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rnk <= 3;
