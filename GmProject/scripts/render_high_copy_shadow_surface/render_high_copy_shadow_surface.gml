/// render_high_copy_shadow_surface(target, source)

function render_high_copy_shadow_surface(target, source)
{
	surface_set_target(target)
	{
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_surface(source, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
}
