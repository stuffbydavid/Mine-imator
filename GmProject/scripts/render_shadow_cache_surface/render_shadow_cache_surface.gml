function render_shadow_cache_surface(key, width, height, depthonly = false)
{
	var surf = ds_map_exists(render_shadow_cache, key) ? render_shadow_cache[?key] : null;
	
	if (!surface_exists(surf) || surface_get_width(surf) != width || surface_get_height(surf) != height)
		ds_map_delete(render_shadow_cache_ready, key)
	
	surf = surface_require(surf, width, height, true, surface_r32float, depthonly)
	render_shadow_cache[?key] = surf
	
	return surf
}
