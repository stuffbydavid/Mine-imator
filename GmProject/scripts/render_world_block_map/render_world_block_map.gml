/// @desc Renders each vertex buffer in the given map, with the key as the chosen texture from the resource.
/// @arg modelmap
/// @arg resource

function render_world_block_map(modelmap, res)
{
	if (modelmap = null)
		return 0
	
	res = res_eval(res)
	render_apply_res(res)
	
	var key = ds_map_find_first(modelmap);
	while (!is_undefined(key))
	{
		var vbuffer = modelmap[?key];
		if (!vbuffer_is_empty(vbuffer))
		{
			var tex;
			with (res)
				tex = res_get_model_texture(key)
			render_set_texture(tex)
			vbuffer_render(vbuffer)
		}
		
		key = ds_map_find_next(modelmap, key)	
	}
}
