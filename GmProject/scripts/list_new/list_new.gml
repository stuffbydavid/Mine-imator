function list_new()
{
	with (new_obj(obj_list))
	{
		item = ds_list_create()
		width = 0 // Update using list_update_width
		update = false
		get_name = false
		toggled = false
		show_ticks = true
		
		return id
	}
}
