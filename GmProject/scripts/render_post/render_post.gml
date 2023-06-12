/// render_post(surface, sceneeffects, posteffects)
/// @surface
/// @sceneeffects
/// @posteffects

function render_post(finalsurf, sceneeffects = true, posteffects = true)
{
	// Start post processing
	finalsurf = render_high_post_start(finalsurf)
	
	// DOF
	if (render_camera_dof && sceneeffects)
		finalsurf = render_high_dof(finalsurf)
	render_update_effects()
	
	// Glow
	if (render_glow && (sceneeffects || posteffects))
		finalsurf = render_high_glow(finalsurf)
	render_update_effects()
	
	// Glow (Falloff)
	if (render_glow_falloff && (sceneeffects || posteffects))
		finalsurf = render_high_glow(finalsurf, true)
	render_update_effects()
	
	// Bloom
	if (render_camera_bloom && posteffects)
		finalsurf = render_high_bloom(finalsurf)
	render_update_effects()
	
	// Lens dirt overlay
	if (render_camera_lens_dirt)
		finalsurf = render_high_lens_dirt(finalsurf)
	render_update_effects()
	
	// Chromatic aberration
	if (render_camera_ca && posteffects)
		finalsurf = render_high_ca(finalsurf)
	render_update_effects()
	
	// Distort
	if (render_camera_distort && posteffects)
		finalsurf = render_high_distort(finalsurf)
	render_update_effects()
	
	// Color correction
	if (render_camera_color_correction && posteffects)
		finalsurf = render_high_cc(finalsurf)
	render_update_effects()
	
	// Film grain
	if (render_camera_grain && posteffects)
		finalsurf = render_high_grain(finalsurf)
	render_update_effects()
	
	// Vignette
	if (render_camera_vignette && posteffects)
		finalsurf = render_high_vignette(finalsurf)
	render_update_effects()
	
	// 2D overlay (camera colors/watermark)
	if (render_overlay && posteffects)
		finalsurf = render_high_overlay(finalsurf)
	render_update_effects()
	
	return finalsurf
}
