/// tl_update_model_shape_vbuffer_map()
/// @desc Updates the vbuffers when the model, bend or texture changes.

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

// Cancel if part is invalid
if (model_part = null)
	return 0

// Create map if unavailable
if (model_shape_vbuffer_map = null)
	model_shape_vbuffer_map = ds_map_create()

// Get resource
var res;
with (temp)
	res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])

model_part_fill_shape_vbuffer_map(model_part, model_shape_vbuffer_map, bend_angle_last, res, temp.model_texture_name_map)