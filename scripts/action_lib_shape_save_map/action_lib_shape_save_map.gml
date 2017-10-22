/// action_lib_shape_save_map()

var fn = file_dialog_save_image(temp_type_name_list[|temp_edit.type]);
if (fn != "")
{
	if (temp_edit.type = e_temp_type.CONE)
		sprite_save_lib(spr_map_cone, 0, fn)
	else if (temp_edit.type = e_temp_type.CUBE)
		sprite_save_lib(spr_map_cube, 0, fn)
	else
		sprite_save_lib(spr_map_cylinder, 0, fn)
}