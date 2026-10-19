/// @arg [filename]

function action_res_replace(fn = "")
{
	var hobj = null;

	if (!history_undo && !history_redo)
	{
		with (res_edit)
		{
			if (fn = "")
				fn = res_load_browse()
			
			if (fn = "")
				return 0
			
			// Reset scenery
			if (type = e_res_type.SCHEMATIC || type = e_res_type.FROM_WORLD)
			{
				scenery_tl_set = false
				scenery_tl_all_types = false
				scenery_tl_types = []
				
				ds_map_clear(scenery_block_map)
				ds_map_clear(scenery_tl_types_count_map)
				
				scenery_tl_types_count_ready = false
			}
			
			filename = filename_name(fn)
			
			load_folder = filename_dir(fn)
			save_folder = app.project_folder
			
			if (type = e_res_type.DOWNLOADED_SKIN)
				type = e_res_type.SKIN
			
			res_load()
		}
		
		hobj = history_set(action_res_replace)
		with (hobj)
		{
			part_amount = 0
			part_child_amount = 0
			
			history_save_tl_select()
		}
		
		tl_deselect_all()
	}
	
	with (obj_template)
	{
		if (scenery = res_edit)
			temp_set_scenery(scenery, !history_undo, hobj)
		
		else if (item_tex = res_edit)
			render_generate_item()
		
		else if (model = res_edit)
		{
			temp_update_model()
			temp_update_model_timeline_tree(hobj)
			temp_update_model_shape()
			temp_update_display_name()
		}
		else if (model_tex = res_edit)
			temp_update_model_shape()
	}
	
	// Restore old timelines
	if (history_undo)
		with (history_data)
			history_restore_parts()
	
	tl_update_length()
	tl_update_list()
	tl_update_matrix()
	
	app_update_tl_edit()
	project_update_counts()
	
	lib_preview.update = true
	res_preview.update = true
	res_preview.reset_view = true
}
