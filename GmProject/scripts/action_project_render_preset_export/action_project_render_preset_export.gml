/// action_project_render_preset_export()
/// @arg [fn]

function action_project_render_preset_export(fn = "")
{
	if (fn = "")
		fn = file_dialog_save_render(render_preset_edit.name)
	
	if (fn = "")
		return 0
		
	if (filename_equals(fn, render_default_file))
	{
		if (!question(text_get("questionsetasdefault")))
			return 0
		
		file_copy_lib(render_default_file, render_default_file + ".backup")
	}
	
	json_save_start(fn)
	json_save_object_start()
	json_save_var("format", render_settings_format)
	json_save_var("created_in", mineimator_version_full)
	json_save_var("name", render_preset_edit.name)
	
	json_save_object_start("render")
	with (render_preset_edit)
	{
		render_preset_save_settings(e_renderer.STANDARD)
		render_preset_save_settings(e_renderer.REALISTIC)
		render_preset_save_settings(e_renderer.COMMON)
		if (!has_fx)
			project_save_render_specialeffects()
		if (!has_graphics)
			project_save_render_graphics()
		if (!has_materials)
			project_save_render_materials()
	}
	json_save_object_done()
	
	json_save_object_done()
	json_save_done()
	
	log("Saved render settings", fn)
	toast_new(e_toast.POSITIVE, text_get("alertrendersaved"))
}