/// temp_update_model_plane_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model or texture changes.

if (model_file = null)
	return 0

if (model_plane_vbuffer_map = null)
	model_plane_vbuffer_map = ds_map_create()

if (model_plane_alpha_map = null)
	model_plane_alpha_map = ds_map_create()
	
// Clear old
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

// Get texture
var res = temp_get_model_texobj(null);

// Go through non-hidden parts
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	if (ds_list_find_index(model_hide_list, model_file.file_part_list[|p].name) < 0)
		model_part_get_plane_vbuffer_map(model_file.file_part_list[|p], model_plane_vbuffer_map, model_plane_alpha_map, res, model_texture_name_map)