/// history_build_action(restore)

function history_build_action(restore)
{
	if (!restore)
	{
		// Detach the preview before undo or redo changes its target
		if (place_target_tl_part_of != null)
			with (place_target_tl_part_of)
				tl_mark_place_target(false)
		
		place_target_tl = null
		place_target_tl_part_of = null
		place_target_tl_model_part = false
		place_view_pos = null
		if (place_tl.parent != app)
			with (place_tl)
				tl_set_parent(app, -1, true)
		
		history_build_shift(false, history_pos)
		return 0
	}

	// Restore the preview after the history action completes
	history_build_shift(true, history_pos)
	place_tl_parent = place_tl.parent
	place_tl_parent_index = ds_list_find_index(place_tl_parent.tree_list, place_tl)
	
	// Restore the editor to the active build preview
	bench_tab = place_history.bench_tab
	
	with (place_tl)
		tl_create_temp_copy(app.bench_settings)
	
	with (bench_settings)
		temp_update(true)
	
	tl_deselect_all()
	tl_update_matrix()
	
	view_main.update_place_surfaces = true
	view_second.update_place_surfaces = true
	obj_edit = place_tl
}
