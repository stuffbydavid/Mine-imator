function project_load_values_update_name(name)
{
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		switch (name)
		{
			case "BG_SKY_CLOUDS_Z":					return "ENV_SKY_CLOUDS_OFFSET_Z"
			case "BRIGHTNESS":						return "EMISSIVE"
			case "CAM_SHAKE_HORIZONTAL_SPEED":		return "CAM_FX_SHAKE_SPEED_X"
			case "CAM_SHAKE_VERTICAL_SPEED":		return "CAM_FX_SHAKE_SPEED_Y"
			case "CAM_SHAKE_HORIZONTAL_STRENGTH":	return "CAM_FX_SHAKE_STRENGTH_X"
			case "CAM_SHAKE_VERTICAL_STRENGTH":		return "CAM_FX_SHAKE_STRENGTH_Y"
		}
	}
	
	if (load_format < e_project.FORMAT_210)
	{
		if (string_pos("CAM_", name) = 1)
		{
			var fxname = "CAM_FX_" + string_delete(name, 1, 4);
			if (ds_list_find_index(value_name_list, fxname) >= 0)
				return fxname
		}
		
		switch (name)
		{
			case "BG_SKY_CLOUDS_OFFSET": return "ENV_SKY_CLOUDS_OFFSET_Y"
			case "BG_SKY_CLOUDS_HEIGHT": return "ENV_SKY_CLOUDS_OFFSET_Z"
		}
	}
	
	if (string_pos("BG_", name) = 1)
		return "ENV_" + string_delete(name, 1, 3)
	
	return name
}
