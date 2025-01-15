with orders as (

select 
id as order_id
,user_id as customer_id 
,order_date 
,status 
from  {{source('jaffle_shop','orders')}} --raw.jaffle_shop.orders
)

select * from orders

--- do we have any new data or not. We can verify source freshness. 
/*
Source freshness should be configured in the YML files. 
To know whethere RAW data has new data or not. When there is new data only , our model will run. 
We can call it as MD5. 
We have to do some look ups. 

we refrence a column for source freshness.  Timestamp will be embedded in the table. That column will be used to see the source freshness.


*/