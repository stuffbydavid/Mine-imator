/// render_free()

function render_free()
{
	// Render targets
	surface_free(render_surface[0])
	surface_free(render_surface[1])
	surface_free(render_surface[2])
	
	// Data
	surface_free(render_surface_depth)
	surface_free(render_surface_normal)
	surface_free(render_surface_normal_ext)
	surface_free(render_surface_emissive)
	surface_free(render_surface_diffuse)
	surface_free(render_surface_material)
	
	// Scene effects
	surface_free(render_surface_ssao)
	surface_free(render_surface_shadows)
	surface_free(render_surface_indirect)
	surface_free(render_surface_specular)
	surface_free(render_surface_ssr)
	
	// Lens dirt
	surface_free(render_surface_lens)
	
	// Samples
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
