/// tl_update_part_plane_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model or texture changes.
	
// Clear old
if (model_plane_vbuffer_map != null)
{
	var key = ds_map_find_first(model_plane_vbuffer_map);
	while (!is_undefined(key))
	{
		var vbuf = model_plane_vbuffer_map[?key];
		vbuffer_destroy(vbuf[0])
		if (vbuf[1] != null)
			vbuffer_destroy(vbuf[1])
		key = ds_map_find_next(model_plane_vbuffer_map, key)	
	}
	ds_map_clear(model_plane_vbuffer_map)
	ds_map_clear(model_plane_alpha_map)
}

// Cancel if no 3D planes are present in the file
if (model_part = null || !model_part.has_3d_plane)
	return 0

// Create maps
if (model_plane_vbuffer_map = null)
{
	model_plane_vbuffer_map = ds_map_create()
	model_plane_alpha_map = ds_map_create()
}

// Get texture
var res;
with (temp)
	res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])

model_part_get_plane_vbuffer_map(model_part, model_plane_vbuffer_map, model_plane_alpha_map, res, temp.model_texture_name_map)

// Update bend mesh
tl_update_bend(true)