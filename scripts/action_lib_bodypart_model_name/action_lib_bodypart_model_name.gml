/// action_lib_bodypart_model_name(name)
/// @arg name
/// @desc Changes the character body part model.

var name, state;

if (history_undo)
{
	name = history_data.old_value
	state = history_data.state
}
else if (history_redo)
{
	name = history_data.new_value
	state = history_data.state
}
else
{
	name = argument0
	with (history_set_var(action_lib_bodypart_model_name, temp_edit.model_name, name, false))
		id.state = temp_edit.model_state
	state = mc_version.model_name_map[?name].default_state
}
	
with (temp_edit)
{
	model_name = name
	model_state = state
	temp_update_model_state_map()
	temp_update_model()
	temp_update_model_part()
	temp_update_display_name()
}

lib_preview.update = true
tl_update_matrix()