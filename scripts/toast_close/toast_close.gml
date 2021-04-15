/// toast_close(toast)
/// @arg alert

var toast;
toast = argument0

if (toast.iid > 0)
	ds_list_add(closed_toast_list, toast.iid)

ds_list_delete_value(toast_list, toast)

with (toast)
	instance_destroy()

settings_save()
