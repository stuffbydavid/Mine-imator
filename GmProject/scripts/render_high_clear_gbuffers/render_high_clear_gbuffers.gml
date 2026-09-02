function render_high_clear_gbuffers()
{
	surface_set_target(render_surface_specular)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	surface_set_target(render_surface_material)
	{
		draw_clear(c_black)
	}
	surface_reset_target()

	surface_set_target(render_surface_depth)
	{
		draw_clear(c_white)
	}
	surface_reset_target()

	surface_set_target(render_surface_normal)
	{
		draw_clear_alpha(c_black, 0)
	}
	surface_reset_target()
}