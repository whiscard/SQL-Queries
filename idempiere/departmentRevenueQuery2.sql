select product.name, store.m_product_id,store.created,store.updated,store.qtyonhand, store.qtyordered, store.datelastinventory
from m_storage store
  inner join m_product product on product.m_product_id = store.m_product_id
order by updated desc;

select product.name,
  store.m_product_id,
  sum(store.qtyonhand) as beginning,
  sum(store.qtyordered) as ordered
from m_storage store
  inner join m_product product on product.m_product_id = store.m_product_id
group by product.name, store.m_product_id;

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