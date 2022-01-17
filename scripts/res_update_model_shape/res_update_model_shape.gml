/// res_update_model_shape()
/// @desc Updates the meshes of the shapes in the resource model.

function res_update_model_shape()
{
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
				model_shape_clear_cache(key)
			key = ds_map_find_next(model_shape_vbuffer_map, key)
		}
		ds_map_clear(model_shape_vbuffer_map)
	}
	
	if (model_file = null)
		return 0
	
	if (model_file.has_3d_plane)
	{
		// Create maps for 3D planes
		if (model_shape_alpha_map = null)
			model_shape_alpha_map = ds_map_create()
	}
	
	// Create map for shape ID->mesh
	if (model_shape_vbuffer_map = null)
		model_shape_vbuffer_map = ds_map_create()
	
	// Get texture (default)
	var res = id;
	if (res.model_texture_map = null)
		res = mc_res
	
	// Go through non-hidden parts
	for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	{
		var part = model_file.file_part_list[|p];
		model_part_fill_shape_alpha_map(part, model_shape_alpha_map, res, model_texture_name_map, model_shape_texture_name_map)
		model_part_fill_shape_vbuffer_map(part, model_shape_vbuffer_map, model_shape_alpha_map, part.bend_inherit_angle)
	}
}
