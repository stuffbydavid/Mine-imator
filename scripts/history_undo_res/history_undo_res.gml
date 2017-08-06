/// history_undo_res()

if (history_data.fn != "" && !history_data.replaced)
{
	with (iid_find(history_data.newres))
	{
		file_delete_lib(app.project_folder + "\\" + filename)
		instance_destroy()
	}
}

return iid_find(history_data.oldres)