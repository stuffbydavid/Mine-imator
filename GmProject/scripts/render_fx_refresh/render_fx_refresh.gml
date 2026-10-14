/// @arg [sceneeffects]
/// @arg [posteffects]
/// @arg [hdr]

function render_fx_refresh(scenefx = true, postfx = true, hdr = false)
{
	var earlyfx = (hdr || renderer_current = e_renderer.QUICK);

	ds_list_clear(render_fx_list)
	ds_list_add(render_fx_list,
		render_camera_dof && scenefx && earlyfx,
		render_glow && scenefx && earlyfx,
		render_camera_bloom && postfx && earlyfx,
		render_camera_lens_dirt && (scenefx || postfx) && earlyfx,
		render_camera_ca && postfx && !hdr,
		render_camera_distort && postfx && !hdr,
		render_camera_cc && postfx && !hdr,
		render_camera_grain && postfx && !hdr,
		render_camera_vignette && postfx && !hdr,
		render_overlay && postfx && !hdr
	)
	
	render_fx_progress = -1
	render_fx_done = false
	render_fx_index = 0
}
