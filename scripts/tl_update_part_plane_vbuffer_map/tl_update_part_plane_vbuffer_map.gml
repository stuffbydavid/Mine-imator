/// tl_update_part_plane_vbuffer_map()
/// @desc Updates the 3D plane vbuffers when the model or texture changes.

if (model_part = null)
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

// Get texture
var texobj, res;
texobj = value_inherit[e_value.TEXTURE_OBJ]
res = temp.model_tex

if (res = null)
	res = temp.model
	
if (texobj != null && texobj.type != e_tl_type.CAMERA)
	res = texobj
				
if (!res.ready || res.model_texture = null || res.model_texture_map = null)
	res = mc_res

model_part_get_plane_vbuffer_map(model_part, model_plane_vbuffer_map, res, temp.model_texture_name_map)