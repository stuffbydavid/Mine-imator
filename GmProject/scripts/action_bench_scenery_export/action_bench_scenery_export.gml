/// action_bench_scenery_export()

function action_bench_scenery_export()
{
	var scenery, source, filename;
	scenery = bench_settings.scenery_selected
	if (scenery = null)
		return 0
	
	if (is_string(scenery))
	{
		filename = scenery + ".schematic"
		source = scenery_directory + bench_scenery_folder + "/" + filename
	}
	else
	{
		filename = scenery.filename
		source = project_folder + "/" + filename
	}
	
	if (!file_exists_lib(source))
		return 0
	
	var fn = file_dialog_save_resource(filename_new_ext(filename, ""), filename_ext(filename))
	if (fn = "")
		return 0
	
	file_copy_lib(source, filename_new_ext(fn, filename_ext(filename)))
}
