/// @arg surface
/// @arg [sceneeffects]
/// @arg [posteffects]
/// @arg [hdr]

function render_fx(finalsurf, scenefx = true, postfx = true, hdr = false)
{
	var earlyfx = (hdr || renderer_current = e_renderer.QUICK);

	gpu_set_blendmode_ext(bm_one, bm_zero)

	// Start post processing
	finalsurf = render_fx_start(finalsurf, hdr)
	
	// DOF
	if (render_camera_dof && scenefx && earlyfx)
		finalsurf = render_fx_dof(finalsurf, hdr)
	render_fx_update()
	
	// Glow
	if (render_glow && scenefx && earlyfx)
		finalsurf = render_fx_glow(finalsurf, hdr)
	render_fx_update()
	
	// Bloom
	if (render_camera_bloom && postfx && earlyfx)
		finalsurf = render_fx_bloom(finalsurf, hdr)
	render_fx_update()
	
	// Lens dirt overlay (scenefx applies to glow, postfx applies to bloom)
	if (render_camera_lens_dirt && (scenefx || postfx) && earlyfx)
		finalsurf = render_fx_lens_dirt(finalsurf, hdr)
	render_fx_update()
	
	// Chromatic aberration
	if (render_camera_ca && postfx && !hdr)
		finalsurf = render_fx_ca(finalsurf)
	render_fx_update()
	
	// Distort
	if (render_camera_distort && postfx && !hdr)
		finalsurf = render_fx_distort(finalsurf)
	render_fx_update()
	
	// Color correction
	if (render_camera_cc && postfx && !hdr)
		finalsurf = render_fx_cc(finalsurf)
	render_fx_update()
	
	// Film grain
	if (render_camera_grain && postfx && !hdr)
		finalsurf = render_fx_grain(finalsurf)
	render_fx_update()
	
	// Vignette
	if (render_camera_vignette && postfx && !hdr)
		finalsurf = render_fx_vignette(finalsurf)
	render_fx_update()
	
	// 2D overlay (camera colors/watermark)
	if (render_overlay && postfx && !hdr)
		finalsurf = render_fx_overlay(finalsurf)
	render_fx_update()
	
	gpu_set_blendmode(bm_normal)

	return finalsurf
}
