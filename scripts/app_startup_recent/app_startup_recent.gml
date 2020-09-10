/// app_startup_recent()

enum e_recent_sort {
	filename_ascend,
	filename_descend,
	date_ascend,
	date_descend
}

recent_display_mode = "list"
recent_sort_mode = e_recent_sort.date_descend

recent_list = ds_list_create()
recent_list_display = ds_list_create()

recent_list_amount = 0
recent_list_update = false

recent_scrollbar = new(obj_scrollbar)

recent_add_wait = false

recent_load()
