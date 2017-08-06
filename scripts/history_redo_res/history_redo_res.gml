/// history_redo_res()

var res;

if (history_data.fn != "" && !history_data.replaced)
{
	res = new_res(history_data.fn, history_data.type)
	res.iid = history_data.newres
	
	if (history_data.type = "skin")
		res.is_skin = temp_edit.char_model.player_skin
	else if (history_data.type = "downloadskin")
		res.is_skin = true
	else if (history_data.type = "itemsheet")
		res.item_sheet_size = history_data.item_sheet_size
		
	with (res)
		res_load()
}
else
	res = iid_find(history_data.newres)

return res
