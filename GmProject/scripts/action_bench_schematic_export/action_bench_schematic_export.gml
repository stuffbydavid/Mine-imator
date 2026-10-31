function action_bench_schematic_export()
{
	var file, source, filename;
	file = bench_settings.schematic_selected
	if (file = null)
		return 0
	
	if (is_string(file))
	{
		filename = file
		source = schematics_directory + bench_schematic_folder + "/" + filename
	}
	else
	{
		filename = file.filename
		source = project_folder + "/" + filename
	}
	
	if (!file_exists_lib(source))
		return 0
	
	var fn = file_dialog_save_resource(filename_new_ext(filename, ""), filename_ext(filename));
	if (fn = "")
		return 0
	
	file_copy_lib(source, filename_new_ext(fn, filename_ext(filename)))
}
