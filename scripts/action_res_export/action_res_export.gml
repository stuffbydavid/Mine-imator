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
	
	load_folder = project_folder
	save_folder = filename_dir(fn)
	with (res_edit)
	{
		res_save()
		file_rename_lib(save_folder + "\\" + filename, fn)
	}
}
