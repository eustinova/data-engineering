drop table calendar cascade;
CREATE TABLE "calendar"
(
dateid serial  NOT NULL,
year        int NOT NULL,
quarter     int NOT NULL,
month       int NOT NULL,
week        int NOT NULL,
date        date NOT NULL,
week_day    varchar(20) NOT NULL,
leap  varchar(20) NOT NULL,
CONSTRAINT PK_calendar PRIMARY KEY ( dateid )
);

truncate table calendar;
--
insert into calendar
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       to_char(date, 'dy') as week_day,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
--checking
select * from calendar;

drop table customer CASCADE; 

CREATE TABLE customer
(
cust_id serial NOT NULL,
customer_id   varchar(8) NOT NULL, --id can't be NULL
 customer_name varchar(22) NOT NULL,
 CONSTRAINT PK_customer PRIMARY KEY ( cust_id )
);

insert into customer select 10+row_number() over(), customer_id, customer_name from (select distinct customer_id, customer_name from orders) a;
select * from customer ;

drop table geography cascade;
CREATE TABLE "geography"
(
 "geo_id"      serial NOT NULL,
 "country"     varchar(17) NOT NULL,
 "city"        varchar(17) NOT NULL,
 "state"       varchar(20) NOT NULL,
 "postal_code" int4 NULL,
 CONSTRAINT "PK_geography" PRIMARY KEY ( "geo_id" )
);

insert into geography select 0+row_number() over(), country, city, state, postal_code from (
select distinct country, city, state, postal_code from orders) o ;

drop table product cascade;
CREATE TABLE "product"
(
 prod_id   serial NOT null,
 "product_id"   varchar(15) NOT NULL,
 "product_name" varchar(127) NOT NULL,
 "category"     varchar(15) NOT NULL,
 "subcategory" varchar(15) NOT NULL,
 "segment"      varchar(15) NOT NULL,
 CONSTRAINT "PK_product" PRIMARY KEY ( "prod_id" )
);

insert into product 
select 100+row_number() over () as prod_id ,product_id, product_name, category, subcategory, segment from (
select distinct product_id, product_name, category, subcategory, segment from orders) o;

CREATE TABLE "shipping"
(
 "ship_id"       int NOT NULL,
 "shipping_mode" varchar(15)  NULL,
 CONSTRAINT "PK_shipping" PRIMARY KEY ( "ship_id" )
);

insert into shipping select 100+row_number() over(), ship_mode from (select distinct ship_mode from orders) a;

drop table sales cascade;
CREATE TABLE "sales"
(
 sales_id      serial NOT NULL,
 cust_id integer NOT NULL,
 order_date_id integer NOT NULL,
 ship_date_id integer NOT NULL,
 prod_id  integer NOT NULL,
 ship_id     integer NOT NULL,
 geo_id      integer NOT NULL,
 order_id    varchar(25) NOT NULL,
 sales       numeric(9,4) NOT NULL,
 profit      numeric(21,16) NOT NULL,
 quantity    int4 NOT NULL,
 discount    numeric(4,2) NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( sales_id ));


insert into sales
select
	 100+row_number() over() as sales_id
	 ,cust_id
	 ,to_char(order_date,'yyyymmdd')::int as  order_date_id
	 ,to_char(ship_date,'yyyymmdd')::int as  ship_date_id
	 ,p.prod_id
	 ,s.ship_id
	 ,geo_id
	 ,o.order_id
	 ,sales
	 ,profit
     ,quantity
	 ,discount
from orders o 
inner join shipping s on o.ship_mode = s.shipping_mode
inner join geography g on o.postal_code = g.postal_code and g.country=o.country and g.city = o.city and o.state = g.state --City Burlington doesn't have postal code
inner join product p on o.product_name = p.product_name and o.segment=p.segment and o.subcategory=p.subcategory and o.category=p.category and o.product_id=p.product_id 
inner join customer c on c.customer_id=o.customer_id and c.customer_name=o.customer_name;


--do you get 9994rows?
select count(*) from sales sl
inner join shipping s on sl.ship_id=s.ship_id
inner join geography g on sl.geo_id=g.geo_id
inner join product p on sl.prod_id=p.prod_id
inner join customer c on sl.cust_id=c.cust_id;

