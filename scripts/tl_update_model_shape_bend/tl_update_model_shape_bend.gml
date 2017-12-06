/// tl_update_model_shape_bend()
/// @desc Updates the shapes of the model part if the bending was changed since the last call.
	
// No change
if (bend_angle_last = value_inherit[e_value.BEND_ANGLE] && bend_model_part_last = model_part)
	return false

// Invalid part, no bending or no shapes
if (model_part = null || model_part.bend_part = null || model_part.shape_list = null)
	return false
	
// Not a body part or no in-between mesh needed
if (type != e_tl_type.BODYPART || (value_inherit[e_value.BEND_ANGLE] = 0 && !model_part.has_3d_plane))
	return false

// Clear old vbuffers
if (model_shape_vbuffer_map != null && ds_map_size(model_shape_vbuffer_map) > 0)
{
	var key = ds_map_find_first(model_shape_vbuffer_map);
	while (!is_undefined(key))
	{
		vbuffer_destroy(model_shape_vbuffer_map[?key])
		key = ds_map_find_next(model_shape_vbuffer_map, key)
	}
	ds_map_clear(model_shape_vbuffer_map)
}

// Create map if unavailable
if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()
	
bend_angle_last = value_inherit[e_value.BEND_ANGLE]
bend_model_part_last = model_part

model_part_fill_shape_vbuffer_map(model_part, model_shape_vbuffer_map, model_shape_alpha_map, value_inherit[e_value.BEND_ANGLE])

return true