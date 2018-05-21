SELECT
    d.Name,
    COUNT(b.bill_id) Cases,
    IF(li.price IS NULL, 0.00, SUM(li.price * li.quantity)) Amount
FROM
    cashier_bill b INNER JOIN cashier_bill_line_item li ON
        b.bill_id = li.bill_id
    INNER JOIN inv_item i ON
        li.item_id = i.item_id
    RIGHT OUTER JOIN inv_department d ON
        i.department_id = d.department_id
        INNER JOIN 
        (
        SELECT
		cbp.bill_id	
		FROM
		cashier_bill_payment cbp
		WHERE
		cbp.payment_mode_id = 1
		AND
		((cbp.date_changed IS NULL AND cbp.date_created BETWEEN '2017-06-16 08:00' AND '2017-06-21 08:00')
        OR
		(cbp.date_changed IS NOT NULL AND cbp.date_changed BETWEEN '2017-06-16 08:00' AND '2017-06-21 08:00'))
		GROUP BY cbp.bill_id
        ) cashpayments
        ON
		b.bill_id = cashpayments.bill_id
WHERE
    b.status = 'PAID'
AND
		((b.date_changed IS NULL AND b.date_created BETWEEN '2017-06-16 08:00' AND '2017-06-21 08:00')
        OR
		(b.date_changed IS NOT NULL AND b.date_changed BETWEEN '2017-06-16 08:00' AND '2017-06-21 08:00'))
GROUP BY d.Name