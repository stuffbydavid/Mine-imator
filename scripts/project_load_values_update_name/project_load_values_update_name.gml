/// project_load_values_update_name(name)
/// @arg name

function project_load_values_update_name(name)
{
	if (load_format < e_project.FORMAT_200_AL10)
	{
		if (name = "BG_SKY_CLOUDS_HEIGHT")
			return "BG_SKY_CLOUDS_Z"
	}
	
	if (load_format < e_project.FORMAT_200_AL26)
	{
		if (name = "BRIGHTNESS")
			return "EMISSIVE"
		
		if (name = "CAM_SHAKE_HORIZONTAL_SPEED")
			return "CAM_SHAKE_SPEED_X"
		
		if (name = "CAM_SHAKE_VERTICAL_SPEED")
			return "CAM_SHAKE_SPEED_Y"
		
		if (name = "CAM_SHAKE_HORIZONTAL_STRENGTH")
			return "CAM_SHAKE_STRENGTH_X"
		
		if (name = "CAM_SHAKE_VERTICAL_STRENGTH")
			return "CAM_SHAKE_STRENGTH_Y"
	}
	
	return name;
}
