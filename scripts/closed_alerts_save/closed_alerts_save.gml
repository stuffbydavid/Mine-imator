/// closed_alerts_save()

log("Saving closed", closed_file)

buffer_current = buffer_create(8, buffer_grow, 1)
buffer_write_byte(ds_list_size(closed_alerts))
for (var a = 0; a < ds_list_size(closed_alerts); a++)
	buffer_write_int(closed_alerts[|a])

buffer_export(buffer_current, closed_file)
buffer_delete(buffer_current)
