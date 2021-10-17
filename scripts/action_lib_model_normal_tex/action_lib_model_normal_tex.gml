/// action_lib_model_normal_tex(resource)
/// @arg resource
/// @desc Sets the model texture of the given library item.

function action_lib_model_normal_tex(res)
{
	var fn;
	fn = ""
	
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		switch (res)
		{
			case e_option.BROWSE: // Load new
			{
				fn = file_dialog_open_image_pack()
				if (!file_exists_lib(fn))
					return 0
				
				var type = e_res_type.SKIN;
				if (temp_edit.type = e_tl_type.MODEL && temp_edit.model != null &&
					temp_edit.model.model_format = e_model_format.BLOCK) // Load as block sheet if the selected model is in .json format
					type = e_res_type.BLOCK_SHEET
				
				res = new_res(fn, type)
				if (temp_edit.model_file != null)
					res.player_skin = temp_edit.model_file.player_skin
				
				with (res)
					res_load()
				
				break
			}
		}
		
		history_set_res(action_lib_model_normal_tex, fn, temp_edit.model_normal_tex, res)
	}
	
	with (temp_edit)
	{
		if (model_normal_tex != null)
			model_normal_tex.count--
		
		model_normal_tex = res
		
		if (model_normal_tex != null)
			model_normal_tex.count++
		
		if (model_name = "banner")
			array_add(banner_update, temp_edit)
	}
	
	lib_preview.update = true
}
