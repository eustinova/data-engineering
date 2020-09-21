SELECT   sum(o.sales) as total_sales,
sum(o.profit) as Total_Profit,
(sum(o.profit) / sum(o.sales) * 100) as Profit_Ratio,
avg(o.discount) as Avg_Discount
FROM public.orders o;

select o.order_id,
sum(o.profit) as Profit_per_Order
from public.orders o
group by o.order_id
order by o.order_id;

select customer_name, customer_id,
sum(sales) as Sales_per_Customer
from orders
group by customer_id, customer_name
order by customer_name;

select 
sum(sales) as Monthly_Sales_by_Segment,
segment,
to_char(order_date, 'YYYY-MM') as o_date 
from orders
group by o_date, segment
order by o_date;

select 
sum(sales) as Monthly_Sales_by_Product_Category,
category,
to_char(order_date, 'YYYY-MM') as o_date 
from orders
group by o_date, category
order by o_date;

--Sales_by_Product_Category_over_time
select sum(sales) as Sales,
category
from orders
group by category 
order by Sales desc;

--Sales and Profit by Customer
select sum(sales) as sales, sum(profit) as profit, customer_id
from orders
group by customer_id
order by sales, profit;

--Sales per region
select 
sum(sales) as sales,
region 
from orders
group by region 
order by sales desc