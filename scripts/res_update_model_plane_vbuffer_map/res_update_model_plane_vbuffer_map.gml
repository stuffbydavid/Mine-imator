/// res_update_model_plane_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model changes.

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
var res = id;
if (res.model_texture_map = null)
	res = mc_res
									
// Go through parts
for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
	model_part_get_plane_vbuffer_map(model_file.file_part_list[|p], model_plane_vbuffer_map, model_plane_alpha_map, res, model_texture_name_map)