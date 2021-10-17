/// action_lib_block_tex_material(resource)
/// @arg resource

function action_lib_block_tex_material(res)
{
	var fn;
	fn = ""
	
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.BLOCK_SHEET)
			with (res)
				res_load()
		}
		
		history_set_res(action_lib_block_tex_material, fn, temp_edit.block_tex_material, res)
	}
	
	with (temp_edit)
	{
		block_tex_material.count--
		block_tex_material = res
		block_tex_material.count++
		
		// Update banner skins
		with (obj_timeline)
		{
			if (type = e_tl_type.SPECIAL_BLOCK && part_root != null)
			{
				if (part_root.temp = temp_edit)
					array_add(banner_update, id)
			}
		}
	}
	
	lib_preview.update = true
}
