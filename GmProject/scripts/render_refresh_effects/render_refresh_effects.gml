/// render_refresh_effects(sceneeffects, posteffects, [hdr])
/// @arg sceneeffects
/// @arg posteffects

function render_refresh_effects(sceneeffects = true, posteffects = true, hdr = false)
{
	var earlyeffects = hdr || renderer_current = e_renderer.QUICK;

	ds_list_clear(render_effects_list)
	ds_list_add(render_effects_list,
		render_camera_dof && sceneeffects && earlyeffects,
		render_glow && sceneeffects && earlyeffects,
		render_camera_bloom && posteffects && earlyeffects,
		render_camera_lens_dirt && (sceneeffects || posteffects) && earlyeffects,
		render_camera_ca && posteffects && !hdr,
		render_camera_distort && posteffects && !hdr,
		render_camera_color_correction && posteffects && !hdr,
		render_camera_grain && posteffects && !hdr,
		render_camera_vignette && posteffects && !hdr,
		render_overlay && posteffects && !hdr
	)
	
	render_effects_progress = -1
	render_post_index = 0
	render_effects_done = false
}
