/// temp_update_model_state_map()
/// @desc Updates the block state map.

var model = mc_assets.model_name_map[?model_name]

if (is_undefined(model))
	return 0

if (model_state_map = null)
	model_state_map = ds_map_create()

ds_map_clear(model_state_map)

if (model_state != "")
	state_vars_string_to_map(model_state, model_state_map)