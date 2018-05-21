SELECT
	i.name item_name,
	IFNULL(begin_stock.qty, 0) beginning,
	IFNULL(incoming_stock.qty, 0) incoming,
	IFNULL(outgoing_stock.qty, 0) outgoing,
	IFNULL(end_stock.qty, 0) ending
	(SELECT (ABS(outgoing)/(incoming+beginning))*100) as PercentUsed
FROM
	inv_stockroom sr INNER JOIN
		(SELECT stockroom_id, item_id, SUM(trans.quantity) AS qty
		 FROM inv_transaction trans INNER JOIN inv_stock_operation op1 ON
			trans.operation_id = op1.stock_operation_id
		 WHERE stockroom_id = $P{stockroomId} AND op1.operation_date <= CONCAT($P{endDate} ,' ' ,'23:59:59')
		 GROUP BY stockroom_id, item_id) end_stock ON
			sr.stockroom_id = end_stock.stockroom_id
	LEFT OUTER JOIN
		(SELECT stockroom_id, item_id, SUM(trans.quantity) AS qty
		 FROM inv_transaction trans INNER JOIN inv_stock_operation op2 ON
			trans.operation_id = op2.stock_operation_id
		 WHERE stockroom_id = $P{stockroomId} AND op2.operation_date  <= $P{beginDate}
		 GROUP BY stockroom_id, item_id) begin_stock ON
			sr.stockroom_id = begin_stock.stockroom_id AND
			end_stock.item_id = begin_stock.item_id
	LEFT OUTER JOIN
		(SELECT stockroom_id, item_id, SUM(trans.quantity) AS qty
		 FROM inv_transaction trans INNER JOIN inv_stock_operation op3 ON
			trans.operation_id = op3.stock_operation_id
		 WHERE stockroom_id = $P{stockroomId} AND op3.operation_date > $P{beginDate} AND op3.operation_date <= CONCAT($P{endDate} ,' ' ,'23:59:59') AND quantity > 0
		 GROUP BY stockroom_id, item_id) incoming_stock ON
			sr.stockroom_id = incoming_stock.stockroom_id AND
			end_stock.item_id = incoming_stock.item_id
	LEFT OUTER JOIN
		(SELECT stockroom_id, item_id, SUM(trans.quantity) AS qty
		 FROM inv_transaction trans INNER JOIN inv_stock_operation op4 ON
			trans.operation_id = op4.stock_operation_id
		 WHERE stockroom_id = $P{stockroomId} AND op4.operation_date > $P{beginDate} AND op4.operation_date <= CONCAT($P{endDate} ,' ' ,'23:59:59') AND quantity <= 0
		 GROUP BY stockroom_id, item_id) outgoing_stock ON
			sr.stockroom_id = outgoing_stock.stockroom_id AND
			end_stock.item_id = outgoing_stock.item_id
	INNER JOIN inv_item i ON
		end_stock.item_id = i.item_id
WHERE
	sr.stockroom_id = $P{stockroomId}
ORDER BY PercentUsed DESC;
