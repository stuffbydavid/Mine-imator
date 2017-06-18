/// action_res_export()

if (res_edit.type = "pack")
{
	var fn = file_dialog_save_image(filename_valid(res_edit.display_name));
	if (fn = "")
		return 0
	fn = filename_new_ext(fn, ".png")
	texture_export(res_preview.last_tex, fn)
}
else
{
	var ext, fn;
	ext = filename_ext(res_edit.filename)
	fn = file_dialog_save_resource(filename_valid(res_edit.display_name), ext)
	if (fn = "")
		return 0
	
	fn = filename_new_ext(fn, ext)
	file_copy_lib(project_folder + "\\" + res_edit.filename, fn)
}
