/// render_refresh_effects()

function render_refresh_effects()
{
	ds_list_clear(render_effects_list)
	ds_list_add(render_effects_list,
		render_volumetric_fog,
		render_camera_dof,
		render_camera_bloom,
		render_glow,
		render_glow_falloff,
		render_aa,
		render_camera_ca,
		render_camera_distort,
		render_camera_lens_dirt,
		render_camera_color_correction,
		render_camera_grain,
		render_camera_vignette,
		render_overlay
	)
	
	render_effects_progress = -1
	render_post_index = 0
	render_effects_done = false
}
