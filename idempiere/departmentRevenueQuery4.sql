  SELECT product.name,
    COALESCE(incoming_stock.qty, (0)::numeric) AS beginning,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS outgoing,
    COALESCE(ending_stock.qty, (0)::numeric) AS ending,
    product.ad_client_id,
    product.ad_org_id
   FROM (((m_product product
     JOIN ( SELECT col.m_product_id,
            sum((col.qtydelivered - col.qtyinvoiced)) AS qty
           FROM (c_orderline col
             JOIN c_order co ON ((col.c_order_id = co.c_order_id)))
          GROUP BY col.m_product_id) ending_stock ON ((product.m_product_id = ending_stock.m_product_id)))
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtydelivered) AS qty
           FROM c_orderline col
          GROUP BY col.m_product_id) incoming_stock ON ((product.m_product_id = incoming_stock.m_product_id)))
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty
           FROM c_orderline col
          GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));

  select qtyonhand from m_storageonhand;

    SELECT product.name,
    COALESCE(beginning_stock.qty, (0)::numeric) AS beginning,
    COALESCE(incoming_stock.qty, (0)::numeric) AS incoming,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS outgoing,
    COALESCE(ending_stock.qty, (0)::numeric) AS ending,
    product.ad_client_id,
    product.ad_org_id
   FROM (((m_product product
     inner join (select sum(beginQty.qtyonhand + col.qtyinvoiced) as qty,
                   beginQty.m_product_id
     from m_storageonhand beginQty
       left join c_orderline col on beginQty.m_product_id = col.m_product_id
       and (col.updated::date between '2018-05-16' AND '2018-05-16')
     where (beginQty.updated::date between '2018-05-16' AND '2018-05-16')
     group by beginQty.m_product_id) beginning_stock on product.m_product_id = beginning_stock.m_product_id
     LEFT JOIN ( SELECT col.m_product_id,
            sum((col.qtydelivered - col.qtyinvoiced)) AS qty
           FROM (c_orderline col
             JOIN c_order co ON ((col.c_order_id = co.c_order_id)))
             where (col.updated::date between '2018-05-16' AND '2018-05-16')
          GROUP BY col.m_product_id) ending_stock ON ((product.m_product_id = ending_stock.m_product_id)))
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtydelivered) AS qty
           FROM c_orderline col
             where (col.updated::date between '2018-05-16' AND '2018-05-16')
          GROUP BY col.m_product_id) incoming_stock ON ((product.m_product_id = incoming_stock.m_product_id)))
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty
           FROM c_orderline col
             where (col.updated::date between '2018-05-16' AND '2018-05-16')
          GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));


      SELECT product.name,
    COALESCE(beginning_stock.qty, (0)::numeric) AS beginning,
    COALESCE(incoming_stock.qty, (0)::numeric) AS incoming,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS outgoing,
    COALESCE(ending_stock.qty, (0)::numeric) AS ending,
    product.ad_client_id,
    product.ad_org_id
   FROM (((m_product product
     inner join (select sum(beginQty.qtyonhand + col.qtyinvoiced) as qty,
                   beginQty.m_product_id
     from m_storageonhand beginQty
       left join c_orderline col on beginQty.m_product_id = col.m_product_id
       and (col.updated::date between '2018-05-16' AND '2018-05-16')
     where (beginQty.updated::date between '2018-05-16' AND '2018-05-16')
     group by beginQty.m_product_id) beginning_stock on product.m_product_id = beginning_stock.m_product_id
     LEFT JOIN ( select sum(beginQty.qtyonhand) as qty,
                   beginQty.m_product_id
     from m_storageonhand beginQty
       where (beginQty.updated::date between '2018-05-16' AND '2018-05-16')
     group by beginQty.m_product_id) ending_stock on product.m_product_id = ending_stock.m_product_id)
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtydelivered) AS qty
           FROM c_orderline col
             where (col.updated::date between '2018-05-16' AND '2018-05-16')
          GROUP BY col.m_product_id) incoming_stock ON ((product.m_product_id = incoming_stock.m_product_id)))
     LEFT JOIN ( SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty
           FROM c_orderline col
             where (col.updated::date between '2018-05-16' AND '2018-05-16')
          GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));

  select * from c_orderline;
  select * from m_storageonhand;