/// action_bench_schematic_export()

function action_bench_schematic_export()
{
	var schematic, source, filename;
	schematic = bench_settings.schematic_selected
	if (schematic = null)
		return 0
	
	if (is_string(schematic))
	{
		filename = schematic + ".schematic"
		source = schematic_directory + bench_schematic_folder + "/" + filename
	}
	else
	{
		filename = schematic.filename
		source = project_folder + "/" + filename
	}
	
	if (!file_exists_lib(source))
		return 0
	
	var fn = file_dialog_save_resource(filename_new_ext(filename, ""), filename_ext(filename))
	if (fn = "")
		return 0
	
	file_copy_lib(source, filename_new_ext(fn, filename_ext(filename)))
}
