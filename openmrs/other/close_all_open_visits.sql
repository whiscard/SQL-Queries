UPDATE visit
  SET date_stopped = SUBDATE(ADDDATE(DATE(date_started), INTERVAL 1 DAY), INTERVAL 1 SECOND),
  changed_by = 1,
  date_changed = NOW()
  WHERE date_stopped IS NULL;