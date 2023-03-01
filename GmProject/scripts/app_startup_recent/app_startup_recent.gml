/// app_startup_recent()

function app_startup_recent()
{
	enum e_recent_sort {
		date_newest,
		date_oldest,
		name_az,
		name_za
	}
	
	recent_display_mode = "grid"
	recent_sort_mode = e_recent_sort.date_newest
	
	recent_list = ds_list_create()
	recent_list_display = ds_list_create()
	recent_thumbnail_width = 240
	recent_thumbnail_height = 180
	
	recent_list_amount = 0
	recent_list_update = false
	
	recent_scrollbar = new_obj(obj_scrollbar)
	recent_scrollbar.snap_value = 44
	
	recent_add_wait = false
	
	recent_load()
}
