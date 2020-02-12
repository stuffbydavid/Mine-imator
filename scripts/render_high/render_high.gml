/// render_high()
/// @desc Renders scene in high quality.

var starttime, finalsurf;

starttime = current_time
render_surface_time = 0

// SSAO
if (setting_render_ssao)
	render_surface_ssao = render_high_ssao()

// Shadows
if (setting_render_shadows)
	render_surface_shadows = render_high_shadows()

// Composite current effects onto the scene
finalsurf = render_high_scene(render_surface_ssao, render_surface_shadows)

// Fog
if (background_fog_show)
	render_surface_fog = render_high_fog()

render_high_scene_post(finalsurf, render_surface_shadows, render_surface_fog)

// Start post processing
render_high_post_start(finalsurf)

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
if (render_glow && setting_render_glow_falloff)
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

render_time = current_time - starttime - render_surface_time
