/// render_surface_pool_event_destroy()

function render_surface_pool_event_destroy()
{
	for (var i = 0; i < array_length(surface); i++)
	{
		surface_free(surface[i])
		surface[i] = null
	}
	for (var i = 0; i < array_length(surface_hdr); i++)
	{
		surface_free(surface_hdr[i])
		surface_hdr[i] = null
	}
	for (var i = 0; i < array_length(surface_hdr_post); i++)
	{
		surface_free(surface_hdr_post[i])
		surface_hdr_post[i] = null
	}
	for (var i = 0; i < array_length(surface_blur); i++)
	{
		surface_free(surface_blur[i])
		surface_blur[i] = null
	}
	for (var i = 0; i < array_length(surface_blur_temp); i++)
	{
		surface_free(surface_blur_temp[i])
		surface_blur_temp[i] = null
	}
	for (var i = 0; i < array_length(surface_post); i++)
	{
		surface_free(surface_post[i])
		surface_post[i] = null
	}

	surface_free(surface_specular_base)
	surface_specular_base = null
	surface_free(surface_depth)
	surface_depth = null
	surface_free(surface_depth_low)
	surface_depth_low = null
	surface_free(surface_normal)
	surface_normal = null
	surface_free(surface_material)
	surface_material = null
	surface_free(surface_diffuse)
	surface_diffuse = null
	surface_free(surface_mask)
	surface_mask = null
	surface_free(surface_shadows)
	surface_shadows = null
	surface_free(surface_specular)
	surface_specular = null
	surface_free(surface_fog)
	surface_fog = null
	surface_free(surface_sss)
	surface_sss = null
	surface_free(surface_sss_range)
	surface_sss_range = null
	surface_free(surface_glow)
	surface_glow = null
	surface_free(surface_indirect_raydata)
	surface_indirect_raydata = null
	surface_free(surface_reflections_raydata)
	surface_reflections_raydata = null
	surface_free(surface_lens)
	surface_lens = null
	surface_free(grain_noise)
	grain_noise = null
	surface_free(surface_samples)
	surface_samples = null

	if (shadow_cache != null)
	{
		var key = ds_map_find_first(shadow_cache)
		while (!is_undefined(key))
		{
			var cache = shadow_cache[?key]
			for (var i = 0; i < array_length(surface_sun_buffer); i++)
				if (surface_sun_buffer[i] = cache)
					surface_sun_buffer[i] = null
			if (surface_spot_buffer = cache)
				surface_spot_buffer = null
			if (surface_point_atlas_buffer = cache)
				surface_point_atlas_buffer = null

			surface_free(cache)
			key = ds_map_find_next(shadow_cache, key)
		}
		ds_map_destroy(shadow_cache)
		shadow_cache = null
	}
	if (shadow_cache_ready != null)
	{
		ds_map_destroy(shadow_cache_ready)
		shadow_cache_ready = null
	}

	for (var i = 0; i < array_length(surface_sun_buffer); i++)
	{
		surface_free(surface_sun_buffer[i])
		surface_sun_buffer[i] = null
	}
	surface_free(surface_spot_buffer)
	surface_spot_buffer = null
	surface_free(surface_point_buffer)
	surface_point_buffer = null
	surface_free(surface_point_atlas_buffer)
	surface_point_atlas_buffer = null

	if (render_surface_pool_current = id)
	{
		render_surface_pool_current = null
		render_surface_pool_clear()
	}
}
