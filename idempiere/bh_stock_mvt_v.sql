create view bh_stock_mvt_v as
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

