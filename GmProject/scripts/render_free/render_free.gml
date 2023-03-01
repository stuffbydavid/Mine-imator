/// render_free()

function render_free()
{
	// Render targets
	surface_free(render_surface[0])
	surface_free(render_surface[1])
	surface_free(render_surface[2])
	
	surface_free(render_surface_hdr[0])
	surface_free(render_surface_hdr[1])
	surface_free(render_surface_hdr[2])
	
	// G-Buffers
	surface_free(render_surface_depth)
	surface_free(render_surface_normal)
	surface_free(render_surface_material)
	surface_free(render_surface_emissive)
	surface_free(render_surface_diffuse)
	
	// Rendering
	surface_free(render_surface_shadows)
	surface_free(render_surface_specular)
	
	// Camera effects
	surface_free(render_surface_lens)
	
	// Sampling
	surface_free(render_surface_sample_expo)
	surface_free(render_surface_sample_dec)
	surface_free(render_surface_sample_alpha)
	
	// Light depth buffers
	for (var i = 0; i < render_cascades_count; i++)
		surface_free(render_surface_sun_buffer[i])
	
	surface_free(render_surface_spot_buffer)
	surface_free(render_surface_point_buffer)
	surface_free(render_surface_point_atlas_buffer)
}
