/// render_high_aa(surface)
/// @arg surface

function render_high_aa(prevsurf)
{
	var resultsurf = render_high_get_apply_surf();

	gpu_set_texrepeat(false)
	gpu_set_texfilter(true)
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)

		render_shader_obj = shader_map[?shader_high_aa]
		with (render_shader_obj)
			shader_use()
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_surface_exists(prevsurf, 0, 0)
		gpu_set_blendmode(bm_normal)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	gpu_set_texfilter(false)
	gpu_set_texrepeat(true)

	return resultsurf
}
