/// render_high_dof(basesurf)
/// @arg basesurf

var prevsurf, depthsurf, resultsurf;
prevsurf = argument0

// Get depth
render_surface[0] = surface_require(render_surface[0], render_width, render_height)
depthsurf = render_surface[0]
surface_set_target(depthsurf)
{
	draw_clear(c_white)
	render_world_start()
	render_world(e_render_mode.HIGH_DOF_DEPTH)
	render_world_done()
}
surface_reset_target()
	
// Render directly to target?
resultsurf = render_high_get_apply_surf()
	
// Apply DOF
surface_set_target(resultsurf)
{
	draw_clear_alpha(c_black, 0)
	gpu_set_texfilter(true)
	gpu_set_texrepeat(false)
		
	render_shader_obj = shader_map[?shader_high_dof]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_high_dof_set(depthsurf)
	}
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
			
	gpu_set_texfilter(false)
	gpu_set_texrepeat(true)
}
surface_reset_target()

return resultsurf
