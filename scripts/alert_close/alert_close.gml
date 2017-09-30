/// alert_close(alert)
/// @arg alert

var alert;
alert = argument0

if (alert.iid > 0)
	ds_list_add(closed_alert_list, alert.iid)

ds_list_delete_value(alert_list, alert)
with (alert)
	instance_destroy()

settings_save()