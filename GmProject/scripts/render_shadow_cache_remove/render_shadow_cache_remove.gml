/// render_shadow_cache_remove(key)

function render_shadow_cache_remove(key)
{
	var surf = render_shadow_cache[?key]
	
	for (var i = 0; i < 3; i++)
		if (render_surface_sun_buffer[i] = surf)
			render_surface_sun_buffer[i] = null
	
	if (render_surface_spot_buffer = surf)
		render_surface_spot_buffer = null
	
	if (render_surface_point_atlas_buffer = surf)
		render_surface_point_atlas_buffer = null
	
	surface_free(surf)
	ds_map_delete(render_shadow_cache, key)
	ds_map_delete(render_shadow_cache_ready, key)
}