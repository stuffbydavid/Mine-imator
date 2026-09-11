/// action_bench_schematic_folder(folder, [update])
/// @arg folder
/// @arg [update]

function action_bench_schematic_folder(folder, update = true)
{
	bench_schematic_folder = folder
	
	var list, selected;
	list = bench_settings.schematic_list
	selected = bench_settings.schematic_selected
	bench_settings.schematic_selected = null
	list.search = false
	list.search_tbx.text = ""
	list.scroll.value = 0
	list.scroll.value_goal = 0
	ds_list_clear(list.list)
	
	if (folder = "project")
	{
		bench_clear()
		bench_settings.scenery = null
		with (bench_settings.preview)
		{
			preview_reset_view()
			self.update = true
		}

		for (var i = 0; i < ds_list_size(res_list.list); i++)
		{
			var res = res_list.list[|i]
			if (res.type = e_res_type.SCENERY || res.type = e_res_type.FROM_WORLD)
				sortlist_add(list, res)
		}
	}
	else
	{
		var dir = schematic_directory + folder + "/"
		if (directory_exists_lib(dir))
		{
			var files = file_find(dir, ".schematic")
			if (is_undefined(files))
				files = array()
			for (var i = 0; i < array_length(files); i++)
			{
				files[i] = filename_new_ext(filename_name(files[i]), "")
			}
			for (var i = 0; i < array_length(files); i++)
				sortlist_add(list, files[i])
		}
	}
	
	if (update)
		sortlist_update(list)
	
	if (folder = "project" && selected != null && ds_list_find_index(list.display_list, selected) >= 0)
	{
		action_bench_schematic_select(selected)
		return 0
	}
	
	if (folder != "project" && is_string(selected) && ds_list_find_index(list.display_list, selected) >= 0)
	{
		var scrollindex = max(0, ds_list_find_index(list.display_list, selected) - 3)
		list.scroll.value = scrollindex * ui_small_height
		list.scroll.value_goal = list.scroll.value
		action_bench_schematic_select(selected)
		return 0
	}
	
	if (folder != "project")
	{
		for (var i = 0; i < array_length(schematic_folders); i++)
		{
			if (schematic_folders[i] != folder)
				continue
			
			var schematic = schematic_default[i]
			for (var s = 0; s < ds_list_size(list.display_list); s++)
			{
				if (list.display_list[|s] = schematic)
				{
					var scrollindex = max(0, s - 3)
					list.scroll.value = scrollindex * ui_small_height
					list.scroll.value_goal = list.scroll.value
					action_bench_schematic_select(schematic)
					break
				}
			}
			break
		}
	}
}
