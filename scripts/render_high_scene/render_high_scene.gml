/// render_high_composite(ssaosurf, shadowsurf)
/// @arg ssaosurf
/// @arg shadowsurf
/// @desc Applies SSAO and shadows onto the scene

var ssaosurf, shadowsurf, resultsurf;
ssaosurf = argument0
shadowsurf = argument1

// Render directly to target?
if (render_effects_done)
{
	render_target = surface_require(render_target, render_width, render_height, true)
	resultsurf = render_target
}
else
{
	render_surface[3] = surface_require(render_surface[3], render_width, render_height, true)
	resultsurf = render_surface[3]
}

surface_set_target(resultsurf)
{
	// Background
	draw_clear_alpha(c_black, 0)
	render_world_background()
	
	// World
	render_world_start()
	render_world_sky()
	render_world(e_render_mode.COLOR_FOG)
	render_world_done()
	
	// 2D mode
	render_set_projection_ortho(0, 0, render_width, render_height, 0)
	
	// Multiply by SSAO
	gpu_set_blendmode_ext(bm_zero, bm_src_color)
	if (setting_render_ssao)
		draw_surface_exists(ssaosurf, 0, 0)
	
	// Multiply by shadows
	if (setting_render_shadows)
	{
		render_shader_obj = shader_map[?shader_high_light_apply]
		with (render_shader_obj)
			shader_use()
		draw_surface_exists(shadowsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	
	// Alpha fix
	gpu_set_blendmode_ext(bm_src_color, bm_one) 
	if (render_background)
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
	else
	{
		render_world_start()
		render_world(e_render_mode.ALPHA_FIX)
		render_world_done()
	}
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()

return resultsurf
