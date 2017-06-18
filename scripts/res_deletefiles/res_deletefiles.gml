/// res_deletefiles()

if (type = "pack")
	directory_delete_lib(app.project_folder + "\\" + filename)
else
	file_delete_lib(app.project_folder + "\\" + filename)
