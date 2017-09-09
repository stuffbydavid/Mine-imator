/// action_lib_scenery(resource)
/// @arg resource
/// @desc Sets the scenery of the given library item.

var res;

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	var fn = "";
	res = argument0
	if (res = e_option.IMPORT_WORLD)
	{
		fn = file_directory + "export.schematic"
		file_delete_lib(fn)
		execute(import_file, fn, true)
		
		if (!file_exists_lib(fn))
			return 0
			
		res = new_res(fn, "fromworld")
		with (res)
			res_load()
	}
	else if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_scenery()
		
		if (!file_exists_lib(fn))
			return 0
			
		res = new_res(fn, "schematic")
		with (res)
			res_load()
	}

	history_set_res(action_lib_scenery, fn, temp_edit.scenery, res)
}

with (temp_edit)
{
	if (scenery != null)
		scenery.count--
	scenery = res
	if (scenery != null)
		scenery.count++
		
	temp_update_display_name()
	temp_update_rot_point()
}

lib_preview.update = true
