/// tl_update_model_shape()
/// @desc Updates the meshes of the shapes in the timeline model.
	
// Clear old alpha arrays
if (model_shape_alpha_map != null)
	ds_map_clear(model_shape_alpha_map)

// Clear old vbuffers
if (model_shape_vbuffer_map != null && ds_map_size(model_shape_vbuffer_map) > 0)
{
	var key = ds_map_find_first(model_shape_vbuffer_map);
	while (!is_undefined(key))
	{
		if (instance_exists(key) && key.vbuffer_default != model_shape_vbuffer_map[?key]) // Don't clear default buffers
			vbuffer_destroy(model_shape_vbuffer_map[?key])
		key = ds_map_find_next(model_shape_vbuffer_map, key)
	}
	ds_map_clear(model_shape_vbuffer_map)
}

if (model_part = null)
	return 0
	
if (model_part.has_3d_plane)
{
	// Create maps for 3D planes
	if (model_shape_alpha_map = null)
		model_shape_alpha_map = ds_map_create()
}
	
// Create map for shape ID->mesh
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