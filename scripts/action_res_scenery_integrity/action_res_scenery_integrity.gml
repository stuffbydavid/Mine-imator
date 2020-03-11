/// action_res_scenery_integrity(value, add)
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
	history_set_var(action_res_scenery_integrity, res_edit.scenery_integrity, res_edit.scenery_integrity * add + val / 100, true)
}

with (res_edit)
	scenery_integrity = scenery_integrity * add + val / 100
	
lib_preview.update = true
