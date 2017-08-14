/// temp_update_char_model_state_map()
/// @desc Updates the block state map.

var model = mc_version.model_name_map[?char_model_name]

if (is_undefined(model))
	return 0

if (char_model_state_map = null)
	char_model_state_map = ds_map_create()

ds_map_clear(char_model_state_map)

if (char_model_state != "")
	block_vars_string_to_map(char_model_state, char_model_state_map)