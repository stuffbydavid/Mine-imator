/// project_load_values_update_default()
/// @desc Updates timeline default values from previous versions

function project_load_values_update_default()
{
	// Old anamorphic ratio was moved into Blade Stretch, anamorphic doesn't rotate with blades (2.1.0)
	if (load_format < e_project.FORMAT_210 && type = e_tl_type.CAMERA)
	{
		var oldratio = value_default[e_value.CAM_DOF_BLUR_RATIO]
		if (load_format < e_project.FORMAT_125)
			oldratio = max(0, oldratio)
		
		value_default[e_value.CAM_BLADE_STRETCH] = -oldratio
		value_default[e_value.CAM_BLADE_ANGLE] = -value_default[e_value.CAM_BLADE_ANGLE]
		value_default[e_value.CAM_DOF_BLUR_RATIO] = 0
	}
}
