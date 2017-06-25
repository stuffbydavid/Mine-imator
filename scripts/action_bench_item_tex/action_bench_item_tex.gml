/// action_bench_item_tex(resource)
/// @arg resource

var res;

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
				popup_importitemsheet_show(fn, action_bench_item_tex)
			
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
	
	var hobj = history_set_res(action_bench_item_tex, fn, bench_settings.item_tex, res);
	hobj.item_sheet_size = popup_importitemsheet.sheet_size
}

with (bench_settings)
{
	item_tex = res
	temp_update_item()
}

bench_settings.preview.update = true
