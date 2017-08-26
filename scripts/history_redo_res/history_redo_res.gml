/// history_redo_res()

var res;

if (history_data.filename != "" && !history_data.replaced)
{
	res = new_res(history_data.type, history_data.filename)
	res.save_id = history_data.new_res_save_id
	
	if (history_data.type = "skin")
		res.is_skin = temp_edit.model_file.player_skin
	else if (history_data.type = "downloadskin")
		res.is_skin = true
	else if (history_data.type = "itemsheet")
		res.item_sheet_size = history_data.item_sheet_size
		
	with (res)
		res_load()
}
else
	res = save_id_find(history_data.new_res_save_id)

return res
