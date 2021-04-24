/// action_res_image_load(filename, type)
/// @arg filename
/// @arg type

function action_res_image_load(fn, type)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var itemsheetsize, hobj, res;
		
		if (history_redo)
		{
			fn = history_data.filename
			type = history_data.type
			if (type = e_res_type.ITEM_SHEET)
				itemsheetsize = history_data.item_sheet_size
		}
		else
		{
			hobj = history_set(action_res_image_load)
			
			if (type = e_res_type.ITEM_SHEET)
			{
				if (popup_importitemsheet.is_sheet)
					itemsheetsize = popup_importitemsheet.sheet_size
				else
					type = e_res_type.TEXTURE
			}
		}
		
		res = new_res(fn, type)
		with (res)
		{
			loaded = true
			if (type = e_res_type.ITEM_SHEET)
				item_sheet_size = itemsheetsize
	
			res_load()
		}
		
		if (!history_redo && !res.replaced)
		{
			with (hobj)
			{
				filename = fn
				id.type = type
				id.item_sheet_size = res.item_sheet_size
				history_save_loaded()
			}
		}
	}
	
	project_reset_loaded()
}
