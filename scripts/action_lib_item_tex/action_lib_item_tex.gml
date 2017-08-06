/// action_lib_item_tex(resource)
/// @arg resource

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	var fn = "";
	res = argument0
	
	switch (res)
	{
		case e_option.BROWSE: // Load new
		{
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
		
			if (filename_ext(fn) = ".zip")
			{
				res = new_res(fn, "pack")
				with (res)
					res_load()
			}
			else
				popup_importitemsheet_show(fn, action_lib_item_tex)
			
			return 0
		}
		
		case e_option.IMPORT_ITEM_SHEET_DONE: // Done importing new item sheet
		{
			fn = popup_importitemsheet.filename
			if (popup_importitemsheet.is_sheet)
			{
				res = new_res(fn, "itemsheet")
				res.item_sheet_size = popup_importitemsheet.sheet_size
			}
			else
				res = new_res(fn, "texture")
				
			with (res)
				res_load()
				
			break
		}
	}
	
	var hobj = history_set_res(action_lib_item_tex, fn, temp_edit.item_tex, res);
	hobj.item_sheet_size = popup_importitemsheet.sheet_size
}

with (temp_edit)
{
	item_tex.count--
	item_tex = res
	item_tex.count++
	temp_update_item()
}

lib_preview.update = true
