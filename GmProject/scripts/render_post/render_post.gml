/// render_post(surface, [sceneeffects, posteffects, hdr])
/// @arg surface
/// @arg sceneeffects
/// @arg posteffects

function render_post(finalsurf, sceneeffects = true, posteffects = true, hdr = false)
{
	var earlyeffects = hdr || renderer_current = e_renderer.QUICK;

	if (hdr)
		gpu_set_blendmode_ext(bm_one, bm_zero)

	// Start post processing
	finalsurf = render_high_post_start(finalsurf, hdr)
	
	// DOF
	if (render_camera_dof && sceneeffects && earlyeffects)
		finalsurf = render_high_dof(finalsurf, hdr)
	render_update_effects()
	
	// Glow
	if (render_glow && sceneeffects && earlyeffects)
		finalsurf = render_high_glow(finalsurf, false, hdr)
	render_update_effects()
	
	// Glow (Falloff)
	if (render_glow_falloff && sceneeffects && earlyeffects)
		finalsurf = render_high_glow(finalsurf, true, hdr)
	render_update_effects()
	
	// Bloom
	if (render_camera_bloom && posteffects && earlyeffects)
		finalsurf = render_high_bloom(finalsurf, hdr)
	render_update_effects()
	
	// Lens dirt overlay (sceneeffects applies to glow, posteffects applies to bloom)
	if (render_camera_lens_dirt && (sceneeffects || posteffects) && earlyeffects)
		finalsurf = render_high_lens_dirt(finalsurf, hdr)
	render_update_effects()
	
	// Chromatic aberration
	if (render_camera_ca && posteffects && !hdr)
		finalsurf = render_high_ca(finalsurf)
	render_update_effects()
	
	// Distort
	if (render_camera_distort && posteffects && !hdr)
		finalsurf = render_high_distort(finalsurf)
	render_update_effects()
	
	// Color correction
	if (render_camera_color_correction && posteffects && !hdr)
		finalsurf = render_high_cc(finalsurf)
	render_update_effects()
	
	// Film grain
	if (render_camera_grain && posteffects && !hdr)
		finalsurf = render_high_grain(finalsurf)
	render_update_effects()
	
	// Vignette
	if (render_camera_vignette && posteffects && !hdr)
		finalsurf = render_high_vignette(finalsurf)
	render_update_effects()
	
	// 2D overlay (camera colors/watermark)
	if (render_overlay && posteffects && !hdr)
		finalsurf = render_high_overlay(finalsurf)
	render_update_effects()
	
	if (hdr)
		gpu_set_blendmode(bm_normal)

	return finalsurf
}
