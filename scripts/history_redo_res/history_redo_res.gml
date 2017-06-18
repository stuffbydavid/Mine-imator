/// history_redo_res()

var res;

if (history_data.fn != "" && !history_data.replaced)
{
	res = new_res(history_data.type, history_data.fn)
	res.filename_out = history_data.fnout
	res.iid = history_data.newres
	if (history_data.type = "skin")
		res.is_skin = temp_edit.char_model.use_skin
	else if (history_data.type = "downloadskin")
		res.is_skin = true
	with (res)
		res_load()
}
else
	res = iid_find(history_data.newres)

return res
