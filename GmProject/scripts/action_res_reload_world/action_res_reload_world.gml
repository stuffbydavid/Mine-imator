/// @desc Reloads the original world selection and replaces its schematic snapshot.

function action_res_reload_world()
{
	if (res_edit = null || res_edit.type != e_res_type.FROM_WORLD)
		return false

	// Restore the selection for this direction through history
	var hobj, loadstart, loadend, oldstart, oldend, loaded;
	hobj = null
	loadstart = array_copy_1d(res_edit.world_box_start_load)
	loadend = array_copy_1d(res_edit.world_box_end_load)
	oldstart = array_copy_1d(res_edit.world_box_start)
	oldend = array_copy_1d(res_edit.world_box_end)
	
	if (history_undo)
	{
		res_edit.world_box_start_load = array_copy_1d(history_data.old_box_start)
		res_edit.world_box_end_load = array_copy_1d(history_data.old_box_end)
	}
	else if (history_redo)
	{
		res_edit.world_box_start_load = array_copy_1d(history_data.new_box_start)
		res_edit.world_box_end_load = array_copy_1d(history_data.new_box_end)
	}

	// Load the requested selection before registering history
	res_edit.world_reload = true
	with (res_edit)
		loaded = res_load_scenery_world()

	if (!loaded)
	{
		res_edit.world_reload = false
		res_edit.world_box_start_load = loadstart
		res_edit.world_box_end_load = loadend
		error("error/load_world")
		return false
	}

	// Save the original parts and both selections once
	if (!history_undo && !history_redo)
	{
		hobj = history_set(action_res_reload_world)
		with (hobj)
		{
			old_box_start = oldstart
			old_box_end = oldend
			new_box_start = array_copy_1d(res_edit.world_box_start_load)
			new_box_end = array_copy_1d(res_edit.world_box_end_load)
			part_amount = 0
			part_child_amount = 0
			history_save_tl_select()
		}
	}

	load_folder = project_folder
	save_folder = project_folder
	with (res_edit)
		res_load(true)

	if (!history_undo && !history_redo)
		tl_deselect_all()

	res_update_reload(hobj)
	
	return true
}
