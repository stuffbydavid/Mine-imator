/// @arg filename

function action_lib_scenery_load(fn)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
		
		if (history_data.scenery_replace_ground)
			env_ground_show = history_data.scenery_ground_show
	}
	else
	{
		var hobj = null;
		
		if (history_redo)
		{
			fn = history_data.filename
			hobj = history_data
		}
		else
		{
			hobj = history_set(action_lib_scenery_load)
			hobj.scenery_replace_ground = setting_scenery_replace_ground
			hobj.scenery_ground_show = env_ground_show
		}
		
		var res = new_res(fn, e_res_type.SCHEMATIC);
		res.loaded = !res.replaced
		if (res.replaced)
		{
			res_edit = res 
			action_res_replace(fn)
		}
		else
			with (res)
				res_load()
		
		with (new_obj(obj_template))
		{
			type = e_temp_type.SCENERY
			scenery = res
			
			block_tex = project_pack_res
			block_tex_material = project_pack_res
			block_tex_normal = project_pack_res
			
			temp_update_display_name()
			temp_update_rot_point()
			
			loaded = true
			with (temp_animate())
			{
				loaded = true
				
				// Wait for queued imports to provide the scenery dimensions
				tl_replace_ground(hobj)
			}
				
			temp_add_lists()
		}
		
		with (hobj)
		{
			filename = fn
			history_save_loaded()
		}
	}
	
	tl_update_list()
	tl_update_matrix()
	
	project_reset_loaded()
	project_update_counts()
}
