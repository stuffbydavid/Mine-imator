/// action_res_scenery_integrity_invert(value)
/// @arg value

var val;

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	history_set_var(action_res_scenery_integrity_invert, res_edit.scenery_integrity_invert, val, true)
}

with (res_edit)
	scenery_integrity_invert = val
	
lib_preview.update = true
