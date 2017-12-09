/// res_update_model_shape()
/// @desc Updates the 3D planes in the model file using the default texture.

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
if (model_file = null || !model_file.has_3d_plane)
	return 0

// Create maps if unavailable
if (model_shape_alpha_map = null)
	model_shape_alpha_map = ds_map_create()
if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()

// Get texture
var res = id;
if (res.model_texture_map = null)
	res = mc_res

// Go through non-hidden parts
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
{
	model_part_fill_shape_alpha_map(model_file.file_part_list[|p], model_shape_alpha_map, res, model_texture_name_map)
	model_part_fill_shape_vbuffer_map(model_file.file_part_list[|p], model_shape_vbuffer_map, model_shape_alpha_map, vec3(0))
}