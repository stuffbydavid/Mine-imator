/// list_init_end()

var list = list_edit;

list_update_width(list)

if (ds_list_size(list.item) > 0 && list.item[|0].divider)
	list.item[|0].divider = false

list_edit = null

return list