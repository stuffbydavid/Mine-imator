/// @desc Updates timeline default values from previous versions.

function project_load_values_update_default(map, values)
{
	if (type != e_tl_type.CAMERA || load_format >= e_project.FORMAT_210)
		return values

	// Restore defaults omitted from older camera files
	var defaults, hasmap;
	defaults = [
		[ e_value.CAM_FX_SHAKE_MODE, 1 ],
		[ e_value.CAM_FX_DOF_RANGE, 200 ],
		[ e_value.CAM_FX_DOF_BLUR_SIZE, .01 ],
		[ e_value.CAM_FX_BLOOM_INTENSITY, .4 ],
		[ e_value.CAM_FX_TONEMAPPER, e_tonemapper.NONE ]
	]
	hasmap = ds_map_valid(map)
	for (var i = 0; i < array_length(defaults); i++)
	{
		var vid, name;
		vid = defaults[i][0]
		name = value_name_list[|vid]
		if (hasmap && (ds_map_exists(map, name) || ds_map_exists(map, string_replace(name, "CAM_FX_", "CAM_"))))
			continue
		
		values[@ vid] = defaults[i][1]
	}

	// Old anamorphic ratio was moved into Blade Stretch, anamorphic doesn't rotate with blades (2.1.0)
	var oldratio = values[e_value.CAM_FX_DOF_BLUR_RATIO];
	if (load_format < e_project.FORMAT_125)
		oldratio = max(0, oldratio)

	values[@ e_value.CAM_FX_BLADE_STRETCH] = -oldratio
	values[@ e_value.CAM_FX_BLADE_ANGLE] = -values[e_value.CAM_FX_BLADE_ANGLE]
	values[@ e_value.CAM_FX_DOF_BLUR_RATIO] = 0

	return values
}
