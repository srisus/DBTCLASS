/*
-- models are nothing but SQL files. 

-- This helps in shaping raw data to transformed data. 
-- each sql file will be a model for us. 
-- we have to write just select statements 
-- these models will act as intermediate views for us. 

-- for first set of transformation - we wil load data into intermediate table.
-- From that table we will apply transformation etc. There is long process of pulling and pushing is happening.
-- We have to take care of DDLs , we need not worry about intermedite tables
-- each model acts as view , it just does the trasnformation and pushes it into next table. 

-- Each model act like transformation. 
--- One model can have multiple transformations ??? 
-- We will use mostly CTEs. 
-- The output will be used by another model. 

-- model to model - we can use one to one or one to many relationship , depends on how we build it.

-- one model output will be input to other model. 
-- second model will use data from 1st model. Each model will have one to one or one to many relation ships. 

-- we can build the lineage in such a way that cascaded effect of one model to another . it means Second model will use o/p of first model as it's input.

-- CTE is common table expressions. They don't store any metadata. Just like views. Without create any intermediate views. 
-- CTEs help immediate data.
--- once code is execued we won't see physical existance of CTE.

-- CTE is also a small dataset. Once execution of code is done , CTE isn't available.

with fsal AS (

    SELECT *,salary+comminsion as final_salary from employees
)
select * from fsal --- here along with old column we will also have new column. 

create view fsal
AS
select * , salary+commision as final_salary from employees 
-- this will store data in the DB. HOwever , in CTE - we can avoid using intermediate objects.
-- This will help for transformation. 

*/

--{{ config(materialized='table') }}
{{
    config(materialized='table')
}}

-- --{% set limit_rows = 200 %}
-- with customers as (

-- select ID as customer_id , first_name , last_name from 
-- raw.jaffle_shop.customers
-- ),
-- orders as (

-- select id as order_id, user_id as customer_id , order_date , status 
-- from raw.jaffle_shop.orders
-- ),

with customers as (

    select * from {{ref('stg_customer')}}
),

orders as (

    select * from {{ref('fact_orders')}}
),

payments as (

    select * from {{ref('stg_payments')}}
),

  customer_orders as (
select customer_id ,order_id,
min (order_date) as first_order_date,
max(order_date) as most_recent_order_date,
count(order_id) as number_of_orders ,
sum(amount) as lifetime_value
from orders 
group by 1,2
),
final as (
select 
customers.customer_id,customers.first_name,customers.last_name,customer_orders.first_order_date,customer_orders.most_recent_order_date
,coalesce(customer_orders.number_of_orders,0) as number_of_orders
,customer_orders.order_id as customer_order_id
,payments.order_id as payments_order_id
,payments.payment_status as payment_status
,payments.payment_amount as payment_amount
,payments.created_date as payment_Date
,customer_orders.lifetime_value
from customers
left join customer_orders using(customer_id)
left join payments using (order_id)
where customer_orders.order_id is not null or payments.order_id is not null 
)
select * from final
-- to be able to run the model we should run dbt run. 

/*
Modularity is the concept of breaking the modlues into small modules.
*/

-- FACT table is more like they have real time data. It has dynamic data.
-- Dimension table is more of attribute specific module data.
-- we can achieve , both dimensional modelling - star schema and snowflake schema. 