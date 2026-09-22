/// render_free()

function render_free()
{
	// Render targets
	surface_free(render_surface[0])
	surface_free(render_surface[1])
	surface_free(render_surface[2])
	
	surface_free(render_surface_hdr[0])
	surface_free(render_surface_hdr[1])
	surface_free(render_surface_hdr_post[0])
	surface_free(render_surface_hdr_post[1])
	surface_free(render_surface_hdr_post[2])
	for (var i = 0; i < 6; i++)
	{
		surface_free(render_surface_blur[i])
		surface_free(render_surface_blur_temp[i])
	}

	surface_free(render_surface_post[0])
	surface_free(render_surface_post[1])
	surface_free(render_surface_specular_base)
	render_gbuffers_cache_ready = false
	
	// G-Buffers
	surface_free(render_surface_depth)
	surface_free(render_surface_depth_low)
	surface_free(render_surface_normal)
	surface_free(render_surface_material)
	surface_free(render_surface_diffuse)
	surface_free(render_surface_mask)
	
	// Rendering
	surface_free(render_surface_shadows)
	surface_free(render_surface_specular)
	surface_free(render_surface_fog)
	surface_free(render_surface_sss)
	surface_free(render_surface_sss_range)
	surface_free(render_surface_glow)
	
	surface_free(render_surface_indirect_raydata)
	surface_free(render_surface_reflections_raydata)
	
	// Camera effects
	surface_free(render_surface_lens)
	
	// Sampling
	surface_free(render_surface_samples)

	for (var pass = 0; pass < array_length(render_pass_surfs); pass++)
		surface_free(render_pass_surfs[pass])
	
	// Light depth buffers
	render_shadow_cache_free()
	for (var i = 0; i < 3; i++)
		surface_free(render_surface_sun_buffer[i])
	
	surface_free(render_surface_spot_buffer)
	surface_free(render_surface_point_buffer)
	surface_free(render_surface_point_atlas_buffer)
}
