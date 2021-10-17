/// action_lib_item_tex_normal(resource)
/// @arg resource

function action_lib_item_tex_normal(res)
{
	var fn;
	fn = ""
	
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		var fn = "";
		
		switch (res)
		{
			case e_option.BROWSE: // Load new
			{
				fn = file_dialog_open_image_pack()
				if (!file_exists_lib(fn))
					return 0
				
				if (filename_ext(fn) = ".zip")
				{
					res = new_res(fn, e_res_type.PACK)
					with (res)
						res_load()
				}
				else
					popup_importitemsheet_show(fn, action_lib_item_tex_normal)
				
				return 0
			}
			
			case e_option.IMPORT_ITEM_SHEET_DONE: // Done importing new item sheet
			{
				fn = popup_importitemsheet.filename
				if (popup_importitemsheet.is_sheet)
				{
					res = new_res(fn, e_res_type.ITEM_SHEET)
					res.item_sheet_size = popup_importitemsheet.sheet_size
				}
				else
					res = new_res(fn, e_res_type.TEXTURE)
				
				with (res)
					res_load()
				
				break
			}
		}
		
		var hobj = history_set_res(action_lib_item_tex, fn, temp_edit.item_tex_normal, res);
		hobj.item_sheet_size = popup_importitemsheet.sheet_size
	}
	
	with (temp_edit)
	{
		item_tex_normal.count--
		item_tex_normal = res
		item_tex_normal.count++
		render_generate_item()
	}
	
	lib_preview.update = true
}
