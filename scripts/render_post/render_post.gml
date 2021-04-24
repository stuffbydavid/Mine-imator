/// render_post(surface)
/// @surface

function render_post(argument0)
{
	var finalsurf = argument0;
	
	// Start post processing
	finalsurf = render_high_post_start(finalsurf);
	
	// Sun volumetrics
	if (render_volumetric_fog)
		finalsurf = render_high_volumetric_fog(finalsurf, render_active = "image" || render_active = "movie")
	render_update_effects()
	
	// DOF
	if (render_camera_dof)
		finalsurf = render_high_dof(finalsurf)
	render_update_effects()
	
	// Bloom
	if (render_camera_bloom)
		finalsurf = render_high_bloom(finalsurf)
	render_update_effects()
	
	// Glow
	if (render_glow)
		finalsurf = render_high_glow(finalsurf)
	render_update_effects()
	
	// Glow (Falloff)
	if (render_glow_falloff)
		finalsurf = render_high_glow(finalsurf, true)
	render_update_effects()
	
	// Anti-Aliasing(FXAA)
	if (render_aa)
		finalsurf = render_high_aa(finalsurf)
	render_update_effects()
	
	// Chromatic aberration
	if (render_camera_ca)
		finalsurf = render_high_ca(finalsurf)
	render_update_effects()
	
	// Distort
	if (render_camera_distort)
		finalsurf = render_high_distort(finalsurf)
	render_update_effects()
	
	// Lens dirt overlay
	if (render_camera_lens_dirt)
		finalsurf = render_high_lens_dirt(finalsurf)
	render_update_effects()
	
	// Color correction
	if (render_camera_color_correction)
		finalsurf = render_high_cc(finalsurf)
	render_update_effects()
	
	// Film grain
	if (render_camera_grain)
		finalsurf = render_high_grain(finalsurf)
	render_update_effects()
	
	// Vignette
	if (render_camera_vignette)
		finalsurf = render_high_vignette(finalsurf)
	render_update_effects()
	
	// 2D overlay (camera colors/watermark)
	if (render_overlay)
		render_high_overlay(finalsurf)
}
