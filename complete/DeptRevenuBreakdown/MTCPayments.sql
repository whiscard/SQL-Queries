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
        INNER JOIN cashier_bill_payment_attribute cbpa ON
		cbp.bill_payment_id = cbpa.bill_payment_id
		WHERE
		cbp.payment_mode_id = 6
		AND 
		cbpa.value_reference = 164110
		AND
		((cbp.date_changed IS NULL AND cbp.date_created BETWEEN '2017-05-31 00:00' AND '2017-05-31 23:59')
        OR
		(cbp.date_changed IS NOT NULL AND cbp.date_changed BETWEEN '2017-05-31 00:00' AND '2017-05-31 23:59'))
		GROUP BY cbp.bill_id
        ) MTCinstitutionpayments
        ON
		b.bill_id = MTCinstitutionpayments.bill_id
WHERE
    b.status = 'PAID'
AND
((b.date_changed IS NULL AND b.date_created BETWEEN '2017-05-31 00:00' AND '2017-05-31 23:59')
        OR
     (b.date_changed IS NOT NULL AND b.date_changed BETWEEN '2017-05-31 00:00' AND '2017-05-31 23:59'))
GROUP BY d.Name