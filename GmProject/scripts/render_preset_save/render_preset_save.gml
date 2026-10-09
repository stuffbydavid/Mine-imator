/// @arg filename

function render_preset_save(fn)
{
	json_save_start(fn)
	json_save_object_start()
	json_save_var("format", render_settings_format)
	json_save_var("created_in", mineimator_version_full)
	json_save_var("name", name)
	
	json_save_object_start("render")
	
		render_preset_save_settings(e_renderer.STANDARD)
		render_preset_save_settings(e_renderer.REALISTIC)
		render_preset_save_settings(e_renderer.COMMON)
	
		// Save missing settings from project
		with (app)
		{
			if (!other.has_fx)
				project_save_render_specialeffects()
	
			if (!other.has_graphics)
				project_save_render_graphics()
	
			if (!other.has_materials)
				project_save_render_materials()
		}
	
	json_save_object_done()
	
	json_save_object_done()
	json_save_done()
}
