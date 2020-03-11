/// action_res_scenery_palette(value)
/// @arg value
/// @arg add

var val;

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	history_set_var(action_res_scenery_palette, res_edit.scenery_palette, val, true)
}

with (res_edit)
	scenery_palette =val
	
lib_preview.update = true
