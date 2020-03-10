/// res_load_browse()
/// @desc Browses for an external file to load.

var fn;

switch (type)
{
	case e_res_type.PACK:
		fn = file_dialog_open_pack()
		break
	
	case e_res_type.SCENERY:
		fn = file_dialog_open_scenery()
		break
	
	case e_res_type.FONT:
		fn = file_dialog_open_font()
		break
		
	case e_res_type.SOUND:
		fn = file_dialog_open_sound()
		break
		
	case e_res_type.MODEL:
		fn = file_dialog_open_model()
		break
		
	default:
		fn = file_dialog_open_image()
		break
}

if (!file_exists_lib(fn))
	return ""

return fn