/// soundlist_event_create()

function soundlist_event_create()
{
	list = ds_list_create()
	display_list = ds_list_create()
	filter_list = ds_list_create()
	filter_scroll = 0
	search_tbx = new_textbox(true, 0, "")
	scroll = new_obj(obj_scrollbar)
	
	header_show = false
	height_items = soundlist_minimum_items
	height_percent = 1
	items_visible = height_items
	
	search = false
	source = ""
	select = null
	selected = null
	selected_name = ""
	script = null
}
