/// action_res_export()

if (res_edit.type = e_res_type.PACK)
{
	var fn = file_dialog_save_image(filename_get_valid(res_edit.display_name));
	if (fn = "")
		return 0
	fn = filename_new_ext(fn, ".png")
	texture_export(res_preview.texture, fn)
}
else
{
	var ext, fn;
	ext = filename_ext(res_edit.filename)
	fn = file_dialog_save_resource(filename_get_valid(res_edit.display_name), ext)
	if (fn = "")
		return 0
	
	fn = filename_new_ext(fn, ext)
	file_copy_lib(project_folder + "\\" + res_edit.filename, fn)
}
