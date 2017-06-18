/// sortlist_event_create()
/// @desc Executed upon the creation of a sorted list.

list = ds_list_create()
columns = 0
column_name[0] = ""
column_text[0] = ""
column_x[0] = 0
column_sort = null
sort_asc = false
filter = false
filter_ani = 0
filter_tbx = new_textbox(true, 0, "")
filter_list = ds_list_create()
scroll = new(obj_scrollbar)
script = null
can_deselect = false
