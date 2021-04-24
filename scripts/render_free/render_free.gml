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
	
	surface_free(render_surface_sun_shadows_expo)
	surface_free(render_surface_sun_shadows_dec)
	surface_free(render_surface_sun_volume_expo)
	surface_free(render_surface_sun_volume_dec)
	
	surface_free(render_surface_indirect)
	surface_free(render_surface_indirect_expo)
	surface_free(render_surface_indirect_dec)
	
	surface_free(render_surface_sun_buffer)
	surface_free(render_surface_sun_color_buffer)
	surface_free(render_surface_spot_buffer)
	for (var d = 0; d < 6; d++)
		surface_free(render_surface_point_buffer[d])
	
	// Free shadow surfaces from lights
	with (obj_timeline)
	{
		if (type = e_tl_type.POINT_LIGHT || type = e_tl_type.SPOT_LIGHT)
		{
			surface_free(light_shadows_decimal_surf)
			surface_free(light_shadows_exponent_surf)
		}
	}
}
