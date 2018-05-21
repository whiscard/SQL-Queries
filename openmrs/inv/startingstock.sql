SELECT
        item.name as item_name,
        stockroom.name as stockroom_name,
        IFNULL(total.stock, 0) AS total_stock,
        IFNULL(starting_stock.stock, 0) AS starting_stock
    FROM
        (SELECT i.name
         FROM inv_item i
         WHERE i.item_id = $P{itemId}
        ) AS item,
        (SELECT s.name
         FROM inv_stockroom s
         WHERE s.stockroom_id = $P{stockroomId}
        ) AS stockroom,
        (SELECT SUM(trans.quantity) AS stock
         FROM inv_transaction trans
         JOIN inv_stock_operation AS iso ON trans.operation_id = iso.stock_operation_id
         WHERE trans.item_id = $P{itemId}
         AND trans.stockroom_id = $P{stockroomId}
         AND iso.operation_date <= CONCAT($P{endDate} ,' ' ,'23:59:59')) total,
        (SELECT SUM(trans.quantity) AS stock
         FROM inv_transaction trans
         JOIN inv_stock_operation AS iso ON trans.operation_id = iso.stock_operation_id
         WHERE trans.item_id = $P{itemId}
         AND trans.stockroom_id = $P{stockroomId}
         AND  iso.operation_date <= $P{beginDate}) AS starting_stock
