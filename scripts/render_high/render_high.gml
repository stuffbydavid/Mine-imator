/// render_high()
/// @desc Renders scene in high quality.

function render_high()
{
	var starttime, finalsurf;
	
	starttime = current_time
	render_surface_time = 0
	render_update_samples()
	
	render_world_start()
	bbox_update_visible()
	render_world_done()
	
	// SSAO
	if (render_ssao)
		render_high_ssao()
	
	// Shadows
	if (render_shadows)
	{
		render_high_shadows(render_active = "image" || render_active = "movie")
	
		if (project_render_pass = e_render_pass.SHADOWS)
			render_pass_surf = surface_duplicate(render_surface_shadows)
		
		if (project_render_pass = e_render_pass.SPECULAR)
			render_pass_surf = surface_duplicate(render_surface_specular)
	}
	
	// Indirect lighting
	if (render_shadows && render_indirect)
	{
		render_high_indirect(render_active = "image" || render_active = "movie")
		
		if (project_render_pass = e_render_pass.INDIRECT)
			render_pass_surf = surface_duplicate(render_surface_indirect)
	}
	
	// Composite current effects onto the scene
	finalsurf = render_high_scene(render_surface_ssao, render_surface_shadows)
	
	// Reflections
	if (render_reflections)
	{
		render_high_reflections(render_active = "image" || render_active = "movie", finalsurf)
		
		if (project_render_pass = e_render_pass.REFLECTIONS)
			render_pass_surf = surface_duplicate(render_surface_ssr, project_render_reflections_halfres ? 2 : 1)
	}
	
	// Fog
	if (background_fog_show)
		render_surface_fog = render_high_fog()
	
	render_high_scene_post(finalsurf, render_surface_shadows, render_surface_fog)
	render_post(finalsurf)
	
	render_samples_clear = false
	
	if (project_render_pass != e_render_pass.COMBINED && surface_exists(render_pass_surf))
		surface_copy(render_target, 0, 0, render_pass_surf)
	
	render_time = current_time - starttime - render_surface_time
}
