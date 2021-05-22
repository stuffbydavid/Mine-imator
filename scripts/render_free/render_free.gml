/// render_free()

function render_free()
{
	surface_free(render_surface[0])
	surface_free(render_surface[1])
	surface_free(render_surface[2])
	surface_free(render_surface[3])
	surface_free(render_surface[4])
	surface_free(render_surface[5])
	
	surface_free(render_surface_lens)
	
	surface_free(render_surface_shadows_expo)
	surface_free(render_surface_shadows_dec)
	
	surface_free(render_surface_sun_volume_expo)
	surface_free(render_surface_sun_volume_dec)
	
	surface_free(render_surface_ssao)
	surface_free(render_surface_shadows)
	surface_free(render_surface_indirect)
	surface_free(render_surface_indirect_expo)
	surface_free(render_surface_indirect_dec)
	
	surface_free(render_surface_ssr)
	surface_free(render_surface_ssr_expo)
	surface_free(render_surface_ssr_dec)
	
	surface_free(render_surface_sss)
	surface_free(render_surface_sss_expo)
	surface_free(render_surface_sss_dec)
	
	surface_free(render_surface_sample_temp1)
	surface_free(render_surface_sample_temp2)
	
	surface_free(render_surface_sun_buffer)
	surface_free(render_surface_sun_color_buffer)
	surface_free(render_surface_spot_buffer)
	for (var d = 0; d < 6; d++)
		surface_free(render_surface_point_buffer[d])
}
