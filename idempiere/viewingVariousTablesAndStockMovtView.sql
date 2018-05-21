select * from c_order order by created desc;
select * from m_product;
select * from c_orderline where ad_org_id=0;
select * from m_storageonhand;
select * from ad_client;
select product.name, sum(col.qtydelivered)
from c_orderline col
inner join m_product product ON col.m_product_id = product.m_product_id
where col.processed = 'Y'
group by product.name;
select product.name, sum(col.qtyinvoiced)
from c_orderline col
inner join m_product product ON col.m_product_id = product.m_product_id
where col.processed = 'Y'
group by product.name;
select product.name, sum(col.qtydelivered - col.qtyinvoiced)
from c_orderline col
inner join m_product product ON col.m_product_id = product.m_product_id
where col.processed = 'Y'
group by product.name;

CREATE OR REPLACE VIEW bh_stock_mvt_v as (
  select
    product.name,
    coalesce(incoming_stock.qty, 0) beginning,
    coalesce(outgoing_stock.qty, 0) outgoing,
    coalesce(ending_stock.qty, 0)   ending,
    product.ad_client_id,
    product.ad_org_id

  from
    m_product product
    inner join
    (select
       col.m_product_id,
       sum(col.qtydelivered - col.qtyinvoiced) as qty
     from c_orderline col
       inner join c_order co on col.c_order_id = co.c_order_id
     group by col.m_product_id
    ) ending_stock ON product.m_product_id = ending_stock.m_product_id
    left join
    (select
       col.m_product_id,
       sum(col.qtydelivered) as qty
     from c_orderline col
     group by col.m_product_id
    ) incoming_stock ON product.m_product_id = incoming_stock.m_product_id
    left join
    (select
       col.m_product_id,
       sum(col.qtyinvoiced) as qty
     from c_orderline col
     group by col.m_product_id
    ) outgoing_stock on product.m_product_id = outgoing_stock.m_product_id
)