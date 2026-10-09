function render_high_clear_gbuffers()
{
	surface_clear(render_surface_specular, c_black)
	surface_clear(render_surface_material, c_black, 0)
	surface_clear(render_surface_depth, c_white)
	surface_clear(render_surface_normal, c_black, 0)

	if (render_auxiliary)
	{
		surface_clear(render_surface_fog, c_black)

		if (render_auxiliary_material || render_pass = e_render_pass.ALL || render_pass = e_render_pass.SUBSURFACE || render_pass = e_render_pass.SUBSURFACE_RANGE)
		{
			surface_clear(render_surface_sss, c_black)
			surface_clear(render_surface_sss_range, c_black)
		}
		
		if (render_glow || render_pass = e_render_pass.ALL || render_pass = e_render_pass.GLOW)
			surface_clear(render_surface_glow, c_black)
	}
}
