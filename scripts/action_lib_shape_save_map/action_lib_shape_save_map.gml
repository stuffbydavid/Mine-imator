/// action_lib_shape_save_map()

var fn = file_dialog_save_image(temp_edit.type);
if (fn != "")
{
	var spr;
	if (type = "cone")
		spr = spr_map_cone
	else if (type = "cube")
		spr = spr_map_cube
	else
		spr = spr_map_cylinder
		
	// TODO save on a surface, when removing Texture.dll
	sprite_save(spr, 0, fn)
}