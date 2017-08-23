/// action_res_image_load(filename, type)
/// @arg filename
/// @arg type

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, type, itemsheetsize, hobj, res;
	
	if (history_redo)
	{
		fn = history_data.filename
		type = history_data.type
		if (type = "itemsheet")
			itemsheetsize = history_data.item_sheet_size
	}
	else
	{
		fn = argument0
		type = argument1
		hobj = history_set(action_res_image_load)
		
		if (type = "itemsheet")
		{
			if (popup_importitemsheet.is_sheet)
				itemsheetsize = popup_importitemsheet.sheet_size
			else
				type = "texture"
		}
	}
	
	res = new_res(fn, type)
	res.loaded = true
	if (type = "itemsheet")
		res.item_sheet_size = itemsheetsize
	
	with (res)
		res_load()
	
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
