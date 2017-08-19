/// action_lib_model_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_model_state.name

tl_deselect_all()

with (temp_edit)
{
	model_state_map[?state] = val
	model_state = state_vars_map_to_string(model_state_map)
	temp_update_model()
	temp_update_display_name()
}

app_update_tl_edit()
tl_update_list()
tl_update_matrix()

lib_preview.update = true