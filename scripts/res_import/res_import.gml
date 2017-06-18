/// res_import()

var fn;

switch (type)
{
	case "pack":
		fn = file_dialog_open_pack()
		break
	
	case "schematic":
		fn = file_dialog_open_scenery()
		break
	
	case "font":
		fn = file_dialog_open_font()
		break
		
	case "sound":
		fn = file_dialog_open_sound()
		break
		
	default:
		fn = file_dialog_open_image()
		break
}

if (file_exists_lib(fn))
{
	filename = filename_name(fn)
	if (type = "pack")
		filename_out = filename_new_ext(filename, "")
	else
		filename_out = filename
	load_folder = filename_dir(fn)
	save_folder = app.project_folder
	if (type = "downloadskin")
		type = "skin"
	res_load()
}
