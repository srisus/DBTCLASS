
WITH PAYMENTS AS(

select 
ID as payment_id ,
	ORDERID as order_id,
	PAYMENTMETHOD as payment_method,
	STATUS as payment_status,
	AMOUNT as payment_amount,
	CREATED as created_date
    from RAW.STRIPE.PAYMENT
)

select * from PAYMENTS