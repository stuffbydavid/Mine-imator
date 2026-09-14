/// action_bench_sound_export()

function action_bench_sound_export()
{
	var slist, selected, row, source, filename, split, ext, fn;
	slist = bench_settings.sound_list_current
	selected = slist.selected
	if (selected = null)
		return 0

	filename = slist.selected_name
	if (filename = "")
	{
		for (var i = 0; i < ds_list_size(slist.display_list); i++)
		{
			row = slist.display_list[|i]
			if (row[2] = selected)
			{
				filename = row[1]
				break
			}
		}
	}

	// Export Minecraft sound
	if (is_string(selected))
	{
		source = minecraft_java_directory_get() + "/assets/objects/" + string_copy(selected, 1, 2) + "/" + selected
		
		split = string_split_escaped(filename, " / ")
		filename = filename_get_valid(split[array_length(split) - 1]) + ".ogg"
	}
	
	// Export resource
	else if (instance_exists(selected) && selected.type = e_res_type.SOUND)
	{
		source = project_folder + "/" + selected.filename
		filename = selected.filename
	}
	else
		return 0

	if (!file_exists_lib(source))
		return 0

	ext = filename_ext(filename)
	fn = file_dialog_save_resource(filename_new_ext(filename, ""), ext)
	if (fn = "")
		return 0

	file_copy_lib(source, filename_new_ext(fn, ext))
}
