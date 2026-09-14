/// soundlist_event_create()

function soundlist_event_create()
{
	list = ds_list_create()
	display_list = ds_list_create()
	filter_list = ds_list_create()
	search_tbx = new_textbox(true, 0, "")
	scroll = new_obj(obj_scrollbar)
	visible_items = 8
	search = false
	source = ""
	select = null
	selected = null
	selected_name = ""
	script = null
}
