/// action_res_import_world(name, regionsdir, boxstart, boxend, filtermode, filterarray)
/// @descImports a piece of a Minecraft world and returns the new resource created.

function action_res_import_world(name, regionsdir, boxstart, boxend, filtermode, filterarray)
{
	var res = null;
	
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var hobj = null;
		if (history_redo)
		{
			name = history_data.name
			regionsdir = history_data.regionsdir
			boxstart = history_data.boxstart
			boxend = history_data.boxend
			filtermode = history_data.filtermode
			filterarray = history_data.filterarray
		}
		else
			hobj = history_set(action_res_import_world)
		
		// Find other resources from same world for final name
		var num = 1;
		with (obj_resource)
			if (type = e_res_type.FROM_WORLD && world_regions_dir = regionsdir)
				num++
		
		var fn = filename_get_valid(name) + (num > 1 ? (" " + string(num)) : "");
		res = new_res(fn, e_res_type.FROM_WORLD);
		with (res)
		{
			loaded = true
			world_regions_dir = regionsdir
			world_box_start = boxstart
			world_box_end = boxend
			world_filter_mode = filtermode
			world_filter_array = filterarray
			res_load()
		}
		
		with (hobj)
		{
			self.name = name
			self.regionsdir = regionsdir
			self.boxstart = boxstart
			self.boxend = boxend
			self.filtermode = filtermode
			self.filterarray = filterarray
			history_save_loaded()
		}
	}
	
	project_reset_loaded()
	return res
}