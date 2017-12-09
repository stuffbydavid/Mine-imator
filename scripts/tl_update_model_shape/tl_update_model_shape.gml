/// tl_update_model_shape()
/// @desc Updates the 3D planes in the model part using the keyframed texture.
	
// Clear old alpha arrays
if (model_shape_alpha_map != null)
	ds_map_clear(model_shape_alpha_map)

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

// Cancel if no 3D planes are available
if (model_part = null || !model_part.has_3d_plane)
	return 0
	
// Create maps if unavailable
if (model_shape_alpha_map = null)
	model_shape_alpha_map = ds_map_create()
if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()

// Get resource
var res;
with (temp)
	res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])

bend_rot_last = vec3(value_inherit[e_value.BEND_ANGLE_X],
					 value_inherit[e_value.BEND_ANGLE_Y],
					 value_inherit[e_value.BEND_ANGLE_Z])
bend_model_part_last = model_part

model_part_fill_shape_alpha_map(model_part, model_shape_alpha_map, res, temp.model_texture_name_map)
model_part_fill_shape_vbuffer_map(model_part, model_shape_vbuffer_map, model_shape_alpha_map, bend_rot_last)