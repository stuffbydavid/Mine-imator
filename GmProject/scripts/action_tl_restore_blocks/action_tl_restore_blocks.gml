/// @desc Restores the selected scenery's source blocks with undo and redo.

function action_tl_restore_blocks()
{
	var hobj, roottl;
	if (history_undo || history_redo)
	{
		hobj = history_data
		roottl = save_id_find(hobj.tl_save_id)
	}
	else
		roottl = tl_edit

	if (roottl = null || roottl.type != e_tl_type.SCENERY || roottl.temp = null || roottl.temp.scenery = null)
		return false

	if (history_undo || history_redo)
	{
		// Restore the exact saved hierarchy, including added blocks and keyframes
		var buildid, save;
		buildid = save_id_get(build_structure)
		save = hobj.save_tl
		if (history_undo)
			save = hobj.old_tl

		with (roottl)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		history_restore_tl(save)

		// Reconnect build mode to the restored timeline instances
		if (buildid != "")
			action_build_structure(save_id_find(buildid))

		with (hobj)
			history_restore_tl_select()
	}
	else
	{
		// Load source parts from file
		with (roottl)
			if (!tl_scenery_load_blocks(true))
				return false

		hobj = history_set(action_tl_restore_blocks)
		hobj.tl_save_id = roottl.save_id

		// Save the edited hierarchy and selection before restoring the source
		with (hobj)
		{
			old_tl = history_save_tl(roottl)
			history_save_tl_select()
		}

		with (roottl)
			tl_scenery_restore()

		// Retain recreated part IDs and the restored hierarchy for redo
		with (hobj)
			save_tl = history_save_tl(roottl)
	}

	place_target_tl = null
	place_block_pos = null
	place_pos = null
	place_view_pos = null
	if (place_target_tl_root != null && !instance_exists(place_target_tl_root))
		place_target_tl_root = null

	build_box_render = null
	
	project_ik_part_array = null
	
	tl_update_list()
	tl_update_length()
	tl_update_matrix()
	
	app_update_tl_edit()
	project_update_counts()
	
	return true
}
