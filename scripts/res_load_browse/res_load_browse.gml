/// res_load_browse()
/// @desc Browses for an external file and loads it.

var fn;

switch (type)
{
	case e_res_type.PACK:
		fn = file_dialog_open_pack()
		break
	
	case e_res_type.SCHEMATIC:
		fn = file_dialog_open_scenery()
		break
	
	case e_res_type.FONT:
		fn = file_dialog_open_font()
		break
		
	case e_res_type.SOUND:
		fn = file_dialog_open_sound()
		break
		
	default:
		fn = file_dialog_open_image()
		break
}

if (!file_exists_lib(fn))
	return 0

filename = filename_name(fn)
load_folder = filename_dir(fn)
save_folder = app.project_folder
if (type = e_res_type.DOWNLOADED_SKIN)
	type = e_res_type.SKIN
	
res_load()
return 1