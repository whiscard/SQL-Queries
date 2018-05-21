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
       sum(col.qtyonhand) as qty
     from m_storageonhand col
     group by col.m_product_id
    ) incoming_stock ON product.m_product_id = incoming_stock.m_product_id
    left join
    (select
       col.m_product_id,
       sum(col.qtyinvoiced) as qty
     from c_orderline col
     group by col.m_product_id
    ) outgoing_stock on product.m_product_id = outgoing_stock.m_product_id