/// sortlist_event_create()
/// @desc Executed upon the creation of a sorted list.

function sortlist_event_create()
{
	list = ds_list_create()
	
	header_show = true
	height_items = list_minimum_items
	height_percent = 0
	items_visible = list_minimum_items
	center_on_draw = false
	
	columns = 0
	column_name[0] = ""
	column_text[0] = ""
	column_x[0] = 0
	column_sort = null
	
	sort_asc = false
	search = false
	search_focused = false
	search_tbx = new_textbox(true, 0, "")
	display_list = ds_list_create()
	scroll = new_obj(obj_scrollbar)
	script = null
	script_select_click = null
	script_search = sortlist_search_default
	
	can_deselect = false
	filter_list = ds_list_create()
	filter_type_list = null
	filter_scroll = 0
}
