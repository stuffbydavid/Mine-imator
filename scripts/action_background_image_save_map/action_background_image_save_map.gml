/// action_background_image_save_map()

function action_background_image_save_map()
{
	var fn = file_dialog_save_image("cube");
	
	if (fn != "")
		sprite_save_lib(spr_map_cube, 0, fn)
}
