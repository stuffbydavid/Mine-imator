/// render_high()
/// @desc Renders scene in high quality.

var starttime, finalsurf;

starttime = current_time
render_surface_time = 0

// SSAO (Render surface 0)
if (setting_render_ssao)
	render_surface_ssao = render_high_ssao()

// Shadows (Use unique surface)
if (setting_render_shadows)
	render_high_shadows(render_active = "image" || render_active = "movie")

// Global Illumination (Use unique surface)
if (setting_render_shadows && setting_render_indirect)
	render_high_indirect(render_active = "image" || render_active = "movie")

// Composite current effects onto the scene
finalsurf = render_high_scene(render_surface_ssao, render_surface_shadows)

// Fog
if (background_fog_show)
	render_surface_fog = render_high_fog()

render_high_scene_post(finalsurf, render_surface_shadows, render_surface_fog)
render_post(finalsurf)

render_shadows_clear = false

if (render_samples < setting_render_shadows_samples)
	render_samples++

render_time = current_time - starttime - render_surface_time
