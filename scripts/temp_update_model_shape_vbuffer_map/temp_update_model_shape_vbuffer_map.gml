/// temp_update_model_shape_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model or texture changes.

// Clear old
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

// Cancel if no 3D planes are present in the file
if (model_file = null)
	return 0

// Create map if unavailable
if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()

// Get texture
var res = temp_get_model_texobj(null);

// Go through non-hidden parts
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	if (ds_list_find_index(model_hide_list, model_file.file_part_list[|p].name) < 0)
		model_part_fill_shape_vbuffer_map(model_file.file_part_list[|p], model_shape_vbuffer_map, 0, res, model_texture_name_map)
		
// Update affected timelines
with (obj_timeline)
	if (temp = other.id)
		tl_update_model_shape_vbuffer_map()