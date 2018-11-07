select
       department.name,
       itemcode.code,
       item.name,
       item.buying_price,
       iip.price as selling_price,
       item.minimum_quantity as reorderLevel

from inv_item item
    left join inv_item_price iip on item.item_id = iip.item_id
    left join inv_item_code itemcode on item.item_id = itemcode.item_id
    left join inv_department department on item.department_id = department.department_id
where item.has_physical_inventory = 0 and item.retired = 0;
