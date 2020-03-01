/// render_high_dof(basesurf)
/// @arg basesurf

var prevsurf, depthsurf, cocsurf, resultsurf;
prevsurf = argument0

// Get depth
render_surface[0] = surface_require(render_surface[0], render_width, render_height, true)
depthsurf = render_surface[0]
surface_set_target(depthsurf)
{
	draw_clear(c_white)
	render_world_start()
	render_world(e_render_mode.DEPTH)
	render_world_done()
}
surface_reset_target()

// Create CoC buffer from depth
render_surface[1] = surface_require(render_surface[1], render_width, render_height)
cocsurf = render_surface[1]
surface_set_target(cocsurf)
{
	draw_clear(c_black)
	
	render_shader_obj = shader_map[?shader_high_dof_coc]
	with (render_shader_obj)
	{
		shader_set(shader)
		shader_high_dof_coc_set(depthsurf)
	}
	draw_blank(0, 0, render_width, render_height)
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
}
surface_reset_target()

// Blur CoC buffer to bleed edges
gpu_set_texrepeat(false)
repeat (16)
{
	var cocsurftemp;
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	cocsurftemp = render_surface[2]
	
	render_shader_obj = shader_map[?shader_high_dof_coc_blur]
	with (render_shader_obj)
		shader_set(shader)
	
	// Horizontal
	surface_set_target(cocsurftemp)
	{
		with (render_shader_obj)
			shader_high_dof_coc_blur_set(1, 0)
		draw_surface_exists(cocsurf, 0, 0)
	}
	surface_reset_target()
	
	// Vertical
	surface_set_target(cocsurf)
	{
		with (render_shader_obj)
			shader_high_dof_coc_blur_set(0, 1)
		draw_surface_exists(cocsurftemp, 0, 0)
	}
	surface_reset_target()
	
	with (render_shader_obj)
		shader_clear()
}
gpu_set_texrepeat(true)

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
		shader_high_dof_set(cocsurf)
	}
	draw_surface_exists(prevsurf, 0, 0)
	with (render_shader_obj)
		shader_clear()
			
	gpu_set_texfilter(false)
	gpu_set_texrepeat(true)
}
surface_reset_target()

return resultsurf
