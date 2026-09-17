/// render_shadow_cache_update(lightlist, sunout)

function render_shadow_cache_update(lightlist, sunout)
{
	if (!render_shadow_cache_enabled)
	{
		if (ds_map_size(render_shadow_cache) > 0)
			render_shadow_cache_free()
		return;
	}
	
	if (ds_map_size(render_shadow_cache) = 0)
	{
		for (var i = 0; i < 3; i++)
		{
			surface_free(render_surface_sun_buffer[i])
			render_surface_sun_buffer[i] = null
		}
		
		surface_free(render_surface_spot_buffer)
		surface_free(render_surface_point_atlas_buffer)
		render_surface_spot_buffer = null
		render_surface_point_atlas_buffer = null
	}
	
	var activekeys = ds_map_create()
	
	if (sunout)
		for (var i = 0; i < render_cascades_count; i++)
			activekeys[?"sun" + string(i)] = true
	
	for (var i = 0; i < array_length(lightlist); i++)
	{
		var light = lightlist[i]
		var lightkey = (light.type = e_tl_type.POINT_LIGHT ? "point:" : "spot:") + light.save_id
		activekeys[?lightkey] = true
	}
	
	var removekeys = []
	var cachekey = ds_map_find_first(render_shadow_cache)
	while (!is_undefined(cachekey))
	{
		if (!ds_map_exists(activekeys, cachekey))
			removekeys = array_add(removekeys, cachekey)
		
		cachekey = ds_map_find_next(render_shadow_cache, cachekey)
	}
	for (var i = 0; i < array_length(removekeys); i++)
		render_shadow_cache_remove(removekeys[i])
	ds_map_destroy(activekeys)
}
