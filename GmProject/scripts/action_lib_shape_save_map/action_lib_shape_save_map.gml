/// action_lib_shape_save_map(type)
/// @arg type

function action_lib_shape_save_map(type)
{
	var fn = file_dialog_save_image(text_get("type" + temp_type_name_list[|type]));
	if (fn != "")
	{
		if (type = e_temp_type.CONE)
			sprite_save_lib(spr_map_cone, 0, fn)
		else if (type = e_temp_type.CUBE)
			sprite_save_lib(spr_map_cube, 0, fn)
		else
			sprite_save_lib(spr_map_cylinder, 0, fn)
	}
}
