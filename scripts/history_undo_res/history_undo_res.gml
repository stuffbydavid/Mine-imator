/// history_undo_res()

if (history_data.filename != "" && !history_data.replaced)
{
	with (save_id_find(history_data.new_res_save_id))
	{
		file_delete_lib(app.project_folder + "\\" + filename)
		instance_destroy()
	}
}

return save_id_find(history_data.old_res_save_id)