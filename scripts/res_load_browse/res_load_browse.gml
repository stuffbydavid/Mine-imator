/// res_load_browse()
/// @desc Browses for an external file and loads it.

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
	load_folder = filename_dir(fn)
	save_folder = app.project_folder
	if (type = "downloadskin")
		type = "skin"
	
	res_load()
}
