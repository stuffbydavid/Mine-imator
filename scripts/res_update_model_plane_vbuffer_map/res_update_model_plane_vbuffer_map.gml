/// res_update_model_plane_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model changes.

if (model_file = null)
	return 0

if (model_plane_vbuffer_map = null)
	model_plane_vbuffer_map = ds_map_create()
	
// Clear old
var key = ds_map_find_first(model_plane_vbuffer_map);
while (!is_undefined(key))
{
	vbuffer_destroy(model_plane_vbuffer_map[?key])
	key = ds_map_find_next(model_plane_vbuffer_map, key)	
}
ds_map_clear(model_plane_vbuffer_map)

// Go through non-hidden parts
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	model_part_get_plane_vbuffer_map(model_file.file_part_list[|p], model_plane_vbuffer_map, mc_res, model_texture_name_map)