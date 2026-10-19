/// @desc Imports a piece of a Minecraft world and returns the new resource created.
/// @arg name
/// @arg regionsdirectory
/// @arg boxstart
/// @arg boxend
/// @arg filterenabled
/// @arg filtermode
/// @arg filterarray
/// @arg extension

function action_res_import_world(name, regionsdir, boxstart, boxend, filterenabled, filtermode, filterarray, ext)
{
	var res = null;
	
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var hobj, fn, worldname;
		hobj = null
		
		if (history_redo)
		{
			fn = history_data.fn
			name = history_data.name
			worldname = history_data.worldname
			regionsdir = history_data.regionsdir
			boxstart = history_data.boxstart
			boxend = history_data.boxend
			filterenabled = history_data.filterenabled
			filtermode = history_data.filtermode
			filterarray = history_data.filterarray
		}
		else
		{
			hobj = history_set(action_res_import_world)

			fn = res_get_world_filename(name, ext)
			worldname = filename_new_ext(fn, "")
		}

		if (filterenabled && filtermode = e_block_filter.REMOVE && array_length(filterarray) = 0)
			filterenabled = false

		res = new_res(project_folder + "/" + fn, e_res_type.FROM_WORLD)
		with (res)
		{
			loaded = true
			scenery_size = point3D(boxend[Z] - boxstart[Z], boxend[X] - boxstart[X], boxend[Y] - boxstart[Y])
			scenery_filter_enabled = filterenabled
			scenery_filter_mode = filtermode
			scenery_filter_array = filterarray
			
			world_regions_dir = regionsdir
			world_name = worldname
			world_reload = !app.history_redo
			world_box_start = boxstart
			world_box_end = boxend
			
			res_load()
		}
		
		with (hobj)
		{
			self.fn = fn
			self.name = name
			self.worldname = worldname
			self.regionsdir = regionsdir
			self.boxstart = boxstart
			self.boxend = boxend
			self.filtermode = filtermode
			self.filterarray = filterarray
			self.filterenabled = filterenabled
			
			history_save_loaded()
		}
	}
	
	project_reset_loaded()
	
	return res
}
