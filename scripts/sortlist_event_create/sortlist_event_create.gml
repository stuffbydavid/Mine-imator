/// sortlist_event_create()
/// @desc Executed upon the creation of a sorted list.

function sortlist_event_create()
{
	list = ds_list_create()
	columns = 0
	column_name[0] = ""
	column_text[0] = ""
	column_x[0] = 0
	column_sort = null
	sort_asc = false
	search = false
	search_tbx = new_textbox(true, 0, "")
	display_list = ds_list_create()
	scroll = new_obj(obj_scrollbar)
	script = null
	can_deselect = false
	filter_list = ds_list_create()
}
