/// @arg [filename]

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
	
	with (render_preset_edit)
		render_preset_save(fn)
	
	log("Saved render settings", fn)
	
	toast_new(e_toast.POSITIVE, text_get("alertrendersaved"))
}
