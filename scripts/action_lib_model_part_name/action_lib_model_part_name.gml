/// action_lib_model_part_name(name)
/// @arg name
/// @desc Changes the character body part.

var name;

if (history_undo)
	name = history_data.oldval
else if (history_redo)
	name = history_data.newval
else
{
	name = argument0
	history_set_var(action_lib_model_part_name, temp_edit.model_part_name, name, false)
}
	
with (temp_edit)
{
	model_part_name = name
	temp_update_model_part()
	temp_update_display_name()
}

lib_preview.update = true
tl_update_matrix()