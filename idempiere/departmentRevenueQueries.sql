select * from m_storageonhand;
select * from m_warehouse;
select * from m_locator;
select * from m_product;
select * from c_orderline;

  SELECT
    product.name as Name,
    warehousename.name,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Cases,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
    product.ad_client_id,
    product.ad_org_id
   FROM m_product product
     inner join ( SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
            FROM c_orderline col
              where col.qtyinvoiced > 0
          GROUP BY col.m_product_id) outgoing_stock ON product.m_product_id = outgoing_stock.m_product_id
    left join m_locator location on product.m_locator_id = location.m_locator_id
    left join m_warehouse warehousename on location.m_warehouse_id = warehousename.m_warehouse_id;

  SELECT
    product.name as Name,
    warehouse.name,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Cases,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
    product.ad_client_id,
    product.ad_org_id
   FROM m_product product
     inner join ( SELECT col.m_product_id,
            col.m_warehouse_id,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
            FROM c_orderline col
              where col.qtyinvoiced > 0
          GROUP BY col.m_product_id,col.m_warehouse_id) outgoing_stock ON product.m_product_id = outgoing_stock.m_product_id
     inner join m_warehouse warehouse on outgoing_stock.m_warehouse_id = warehouse.m_warehouse_id;


SELECT warehouse.name as warehousename,
                  col.m_product_id
                FROM c_orderline col
                  inner join m_warehouse warehouse on col.m_warehouse_id = warehouse.m_warehouse_id
          group by warehousename,m_product_id) warehouse ON outgoing_stock.m_product_id = warehouse.m_product_id

SELECT
  warehouse.name as Name,
  COALESCE(outgoing_stock.cases, (0)::numeric) AS Cases,
  COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
  warehouse.ad_client_id,
  warehouse.ad_org_id
FROM m_warehouse warehouse
  inner join
    (
    select col.m_warehouse_id,
      col.updated,
    count(col.c_orderline_id) AS cases,
    sum((col.priceentered * col.qtyinvoiced)) AS price
    FROM c_orderline col
    where col.qtyinvoiced > 0
    GROUP BY col.m_warehouse_id, col.updated) outgoing_stock ON warehouse.m_warehouse_id = outgoing_stock.m_warehouse_id

where outgoing_stock.updated between $P{beginDate} AND $P{endDate};

SELECT
  warehouse.name as Name,
  COALESCE(outgoing_stock.cases, (0)::numeric) AS Cases,
  COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
  warehouse.ad_client_id,
  warehouse.ad_org_id
FROM m_warehouse warehouse
  inner join
    (
    select col.m_warehouse_id,

    count(col.c_orderline_id) AS cases,
    sum((col.priceentered * col.qtyinvoiced)) AS price
    FROM c_orderline col
    where col.qtyinvoiced > 0
    GROUP BY col.m_warehouse_id) outgoing_stock ON warehouse.m_warehouse_id = outgoing_stock.m_warehouse_id;


SELECT
  warehouse.Name as Name,
  COALESCE(outgoing_stock.cases, (0)::numeric) AS Cases,
  COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
  warehouse.ad_client_id,
  warehouse.ad_org_id
FROM m_warehouse warehouse
  inner join
    (
    select col.m_warehouse_id,
    count(col.c_orderline_id) AS cases,
    sum((col.priceentered * col.qtyinvoiced)) AS price
    FROM c_orderline col
    where col.qtyinvoiced > 0
    and (col.updated between $P{beginDate} AND $P{endDate})
    GROUP BY col.m_warehouse_id) outgoing_stock ON warehouse.m_warehouse_id = outgoing_stock.m_warehouse_id;

SELECT
    warehouse.m_warehouse_id as department_id,
    warehouse.name as Department
FROM
 m_warehouse as warehouse
WHERE
    warehouse.ad_client_id =  $P{AD_CLIENT_ID}
    and warehouse.ad_org_id =  $P{AD_CLIENT_ID};


SELECT
    product.name as Name,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Cases,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
    product.ad_client_id,
    product.ad_org_id
   FROM (m_product product
     INNER JOIN
     (
       SELECT col.m_product_id,
            warehouse.name,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
       FROM c_orderline col
              inner join m_warehouse warehouse on col.m_warehouse_id = warehouse.m_warehouse_id
              where col.qtyinvoiced > 0
       GROUP BY col.m_product_id, warehouse.name) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));

SELECT
    product.name as Item,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Count,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount,
    product.ad_client_id,
    product.ad_org_id
   FROM (m_product product
     INNER JOIN
     (
       SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
       FROM c_orderline col
              where col.qtyinvoiced > 0
              and (col.updated between $P{beginDate} AND $P{endDate})
              and col.m_warehouse_id = $P{departmentId}
       GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));


SELECT
    product.name as Item,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Count,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount
FROM (m_product product
     INNER JOIN
     (
       SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
       FROM c_orderline col
              where col.qtyinvoiced > 0
              and col.m_warehouse_id = 1000005
       GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)));

SELECT
    warehouse.m_warehouse_id as department_id,
    warehouse.name as Department
FROM
 m_warehouse as warehouse;

SELECT
    col.m_warehouse_id as department_id,
    warehouse.name as Department
FROM
    c_orderline col
  inner join m_warehouse warehouse on col.m_warehouse_id = warehouse.m_warehouse_id;

SELECT
    product.name as Item,
    COALESCE(outgoing_stock.qty, (0)::numeric) AS Count,
    COALESCE(outgoing_stock.price, (0)::numeric) AS Amount
   FROM (m_product product
     INNER JOIN
     (
       SELECT col.m_product_id,
            sum(col.qtyinvoiced) AS qty,
            sum((col.priceentered * col.qtyinvoiced)) AS price
       FROM c_orderline col
              where col.qtyinvoiced > 0
              and (col.updated::date between '2018-05-14' AND '2018-05-14')
              and col.m_warehouse_id = 1000005
       GROUP BY col.m_product_id) outgoing_stock ON ((product.m_product_id = outgoing_stock.m_product_id)))


