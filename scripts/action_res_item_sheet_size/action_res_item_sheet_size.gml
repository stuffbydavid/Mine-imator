/// action_res_item_sheet_size(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_res_item_sheet_size, res_edit.item_sheet_size[axis_edit], res_edit.item_sheet_size[axis_edit] * add + val, true)
}

with (res_edit)
	item_sheet_size[axis_edit] = item_sheet_size[axis_edit] * add + val

with (obj_template)
	if (item_tex = res_edit)
		render_generate_item()
	
lib_preview.update = true
