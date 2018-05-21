select * from cashier_bill where date_format(date_created, '%Y-%m') = '2016-08';
select * from cashier_bill_payment where date_format(date_created, '%Y-%m') = '2016-08';
select * from cashier_bill_payment_attribute order by bill_payment_id desc;
select * from cashier_payment_mode_attribute_type;
select * from cashier_payment_mode;
select * from cashier_bill_payment_attribute where value_reference like '%marira%' or 
value_reference like '%marira%' order by bill_payment_id desc;
select * from cashier_bill_payment_attribute where value_reference like '%kijabe%' or 
value_reference like '%kijabe%' order by bill_payment_id desc;
select * from cashier_bill_payment_attribute where payment_mode_attribute_type_id = 3;
select * from cashier_bill_payment_attribute where bill_payment_id = 62513;
