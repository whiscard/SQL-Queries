SELECT
inv_item.name as InventoryItemName, 
COUNT(inv_item.name) AS NoOfTransactions, 
SUM(inv_trans.quantity) AS AmountTransfered,
source_inv_stroom.name AS SourceStockroom,
dest_inv_stroom.name AS DestinationStockroom

FROM inv_transaction AS inv_trans
	INNER JOIN inv_stock_operation inv_sto
	ON inv_trans.operation_id = inv_sto.stock_operation_id
	INNER JOIN inv_item 
	ON inv_item.item_id = inv_trans.item_id
    INNER JOIN inv_stockroom source_inv_stroom
    ON source_inv_stroom.stockroom_id = inv_sto.source_id
    AND inv_sto.status = 'COMPLETED'
    INNER JOIN inv_stockroom dest_inv_stroom
    ON dest_inv_stroom.stockroom_id = inv_sto.destination_id
    AND inv_sto.status = 'COMPLETED'
    
WHERE inv_sto.operation_type_id = 6
AND (inv_sto.source_id =  $P{sourceStockroomID} AND inv_sto.destination_id =  $P{destinationStockroomID} 
AND inv_trans.stockroom_id =  $P{destinationStockroomID})
AND (inv_trans.date_created BETWEEN  $P{beginDatePattern} AND  $P{endDatePattern})
GROUP BY inv_item.name;
