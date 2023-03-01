/// toast_close(toast)
/// @arg alert

function toast_close(toast)
{
	if (toast.iid > 0)
		ds_list_add(closed_toast_list, toast.iid)
	
	ds_list_delete_value(toast_list, toast.id)
	
	if (toast.iid > 0)
		settings_save()
		
	with (toast)
		instance_destroy()
}
