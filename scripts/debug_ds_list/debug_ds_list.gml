/// debug_ds_list(list)
/// @arg map

var list = argument0;

debug("Elements", ds_list_size(list))
for (var i = 0; i < ds_list_size(list); i++)
	debug("    " + string(list[|i]))