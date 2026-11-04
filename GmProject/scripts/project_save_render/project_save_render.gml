function project_save_render()
{
	json_save_object_start("render")
		
		// Standard renderer performance settings
		with (render_preset_map[?project_render_preset[e_renderer.STANDARD]])
			render_preset_save_settings(e_renderer.STANDARD)

		// Realistic renderer performance settings
		with (render_preset_map[?project_render_preset[e_renderer.REALISTIC]])
			render_preset_save_settings(e_renderer.REALISTIC)
		
		// Project settings
		project_save_render_specialeffects()
		project_save_render_graphics()
		project_save_render_materials()
		
	json_save_object_done()
}
