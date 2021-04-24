/// history_redo_res()

function history_redo_res()
{
	var res;
	
	if (history_data.filename != "" && !history_data.replaced)
	{
		res = new_res(history_data.filename, history_data.type)
		res.save_id = history_data.new_res_save_id
		
		if (history_data.type = e_res_type.SKIN)
			res.player_skin = history_data.player_skin
		else if (history_data.type = e_res_type.DOWNLOADED_SKIN)
			res.player_skin = true
		else if (history_data.type = e_res_type.ITEM_SHEET)
			res.item_sheet_size = array_copy_1d(history_data.item_sheet_size)
		
		with (res)
			res_load()
	}
	else
		res = save_id_find(history_data.new_res_save_id)
	
	return res
}
