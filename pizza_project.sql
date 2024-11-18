use pizzahut;
select* from order_details;
select* from orders;
select* from pizza_types;
select* from pizzas;


--1.Retrieving the total number of orders placed.
select count(*) as total_orders from orders ;
--2.Calculating the total revenue generated from pizza sales.

select sum(order_details.quantity*pizzas.price) as total_revenue  from order_details join
pizzas on order_details.pizza_id=pizzas.pizza_id ;

--3.Identifing  the highest-priced pizza.
select pizza_types.name ,pizzas.price from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id order by price desc OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;

--4.Identifing  the most common pizza size ordered.
select pizzas.size,count(order_details.order_details_id) as orders_count from pizzas join
order_details on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by orders_count desc OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;

--5.Top 5 most ordered pizza types along with their quantities.
select count(order_details_id)as total_orders ,pizza_types.name from order_details 
join pizzas on order_details.pizza_id=pizzas.pizza_id join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id group by pizza_types.name order by total_orders desc OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY;

--6.finding the total quantity of each pizza category ordered.


select sum(order_details.quantity) as quantity ,pizza_types.category from order_details 
join pizzas on order_details.pizza_id=pizzas.pizza_id join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id group by pizza_types.category order by quantity desc;

--7.finding the category-wise distribution of pizzas.

   select category , count(name) as total from pizza_types group by category order by total desc;

--8.Grouping the orders by date and calculate the average number of pizzas ordered per day.


select avg(quantity) as avg_no_of_pizzas_ordered_per_day from 
(select orders.date,sum(order_details.quantity) as quantity
   from 
   orders 
   join order_details on orders.order_id=order_details.order_id

   group by orders.date) as order_quantity;


--9.Determine the top 5 most ordered pizza types based on revenue.


select pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue from order_details 
join pizzas on order_details.pizza_id=pizzas.pizza_id join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id group by pizza_types.name order by revenue desc OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY;


--10.percentage contribution of each pizza type to total revenue.
select pizza_types.category,round(sum(order_details.quantity *pizzas.price)/(select round(sum(order_details.quantity *pizzas.price),2)
as total_sales 
from
    order_details
	join
	pizzas on pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
    from pizza_types join pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
	join order_details
	on order_details.pizza_id =pizzas.pizza_id
	group by pizza_types .category order by revenue desc;

--11.Analyze the cumulative revenue generated over time.

    SELECT date, SUM(revenue) OVER (ORDER BY date) AS cum_rev
    FROM (
        SELECT orders.date, SUM(order_details.quantity * pizzas.price) AS revenue
        FROM order_details
        JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN orders ON orders.order_id = order_details.order_id
        GROUP BY orders.date
    ) AS daily_revenue

--12 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) as revenue from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b where rn <= 3;










