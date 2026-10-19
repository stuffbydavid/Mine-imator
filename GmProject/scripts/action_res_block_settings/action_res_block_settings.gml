/// @desc Apply block settings to the current resource.

function action_res_block_settings(tlalltypes, tltypes, integrity, palette, randomizeblocks, filterenabled, filtermode, filterarray)
{
	var hobj = null;
	if (history_undo || history_redo)
	{
		with (history_data)
		{
			if (history_undo)
			{
				tlalltypes = old_tl_all_types
				tltypes = old_tl_types
				integrity = old_integrity
				palette = old_palette
				randomizeblocks = old_randomize
				filterenabled = old_filter_enabled
				filtermode = old_filter_mode
				filterarray = old_filter_array
			}
			else
			{
				tlalltypes = new_tl_all_types
				tltypes = new_tl_types
				integrity = new_integrity
				palette = new_palette
				randomizeblocks = new_randomize
				filterenabled = new_filter_enabled
				filtermode = new_filter_mode
				filterarray = new_filter_array
			}
		}
	}
	else
	{
		hobj = history_set(action_res_block_settings)
		with (hobj)
		{
			old_tl_all_types = res_edit.scenery_tl_all_types
			old_tl_types = array_copy_1d(res_edit.scenery_tl_types)
			old_integrity = res_edit.scenery_integrity
			old_palette = res_edit.scenery_palette
			old_randomize = res_edit.scenery_randomize
			old_filter_enabled = res_edit.scenery_filter_enabled
			old_filter_mode = res_edit.scenery_filter_mode
			old_filter_array = array_copy_1d(res_edit.scenery_filter_array)
		
			new_tl_all_types = tlalltypes
			new_tl_types = array_copy_1d(tltypes)
			new_integrity = integrity
			new_palette = palette
			new_randomize = randomizeblocks
			new_filter_enabled = filterenabled
			new_filter_mode = filtermode
			new_filter_array = array_copy_1d(filterarray)
		
			part_amount = 0
			part_child_amount = 0
		
			history_save_tl_select()
		}
		
		tl_deselect_all()
	}

	with (res_edit)
	{
		scenery_tl_all_types = tlalltypes
		scenery_tl_types = array_copy_1d(tltypes)
		scenery_integrity = integrity
		scenery_palette = palette
		scenery_randomize = randomizeblocks
		scenery_filter_enabled = filterenabled
		scenery_filter_mode = filtermode
		scenery_filter_array = array_copy_1d(filterarray)

		load_folder = app.project_folder
		save_folder = app.project_folder
		
		res_load(true)
	}

	res_update_reload(hobj)
}
