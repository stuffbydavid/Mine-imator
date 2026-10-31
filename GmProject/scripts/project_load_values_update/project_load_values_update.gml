/// @desc Updates values from previous versions.

function project_load_values_update(map = null)
{
	// More background values can be keyframed (1.2.0)
	if (load_format < e_project.FORMAT_120_PRE_3)
	{
		if (timeline.type = e_tl_type.ENVIRONMENT)
		{
			value[e_value.ENV_IMAGE_SHOW] = app.env_background_image_show
			
			value[e_value.ENV_SUNLIGHT_STRENGTH] = app.env_sunlight_strength
			
			value[e_value.ENV_SKY_CLOUDS_SHOW] = app.env_sky_clouds_show
			value[e_value.ENV_SKY_CLOUDS_OFFSET_Z] = app.env_sky_clouds_offset_z
			
			value[e_value.ENV_GROUND_SHOW] = app.env_ground_show
			
			for (var i = e_biome_color.GRASS; i <= e_biome_color.WATER; i++)
				value[e_value.ENV_GRASS_COLOR + i] = app.env_color_list[i]
			
			value[e_value.ENV_FOG_SHOW] = app.env_fog_show
			value[e_value.ENV_FOG_SKY] = app.env_fog_sky
			value[e_value.ENV_FOG_CUSTOM_COLOR] = app.env_fog_color_custom
			value[e_value.ENV_FOG_CUSTOM_OBJECT_COLOR] = app.env_fog_custom_object_color
		
			value[e_value.ENV_WIND] = app.env_wind
		}
	}
	
	// Changed how anamorphic effects work, keyframable ground texture (1.2.5)
	if (load_format < e_project.FORMAT_125)
	{
		if (timeline.type = e_tl_type.CAMERA)
		{
			value[e_value.CAM_FX_BLOOM_RATIO] = max(0, value[e_value.CAM_FX_BLOOM_RATIO])
			value[e_value.CAM_FX_DOF_BLUR_RATIO] = max(0, value[e_value.CAM_FX_DOF_BLUR_RATIO])
		}
		
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_GROUND_SLOT] = app.env_ground_slot
	}
	
	// Old anamorphic ratio was moved into Blade Stretch, anamorphic doesn't rotate with blades (2.1.0)
	if (load_format < e_project.FORMAT_210 && timeline.type = e_tl_type.CAMERA && load_format > e_project.FORMAT_123_PRE_2)
	{
		if (ds_map_valid(map))
		{
			if (ds_map_exists(map, "CAM_BLADE_ANGLE") || ds_map_exists(map, "CAM_FX_BLADE_ANGLE"))
				value[e_value.CAM_FX_BLADE_ANGLE] = -value[e_value.CAM_FX_BLADE_ANGLE]
			
			if (ds_map_exists(map, "CAM_DOF_BLUR_RATIO") || ds_map_exists(map, "CAM_FX_DOF_BLUR_RATIO"))
				value[e_value.CAM_FX_BLADE_STRETCH] = -value[e_value.CAM_FX_DOF_BLUR_RATIO]
		}
		
		value[e_value.CAM_FX_DOF_BLUR_RATIO] = 0
	}

	// Separated leaf colors for custom biome setting (2.0.0)
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		for (var i = e_biome_color.LEAVES_OAK; i < e_biome_color.amount; i++)
		{
			app.env_color_list[i] = app.env_color_list[e_biome_color.FOLIAGE]
			value[e_value.ENV_GRASS_COLOR + i] = value[e_value.ENV_FOLIAGE_COLOR]
		}
		
		app.env_color_list[e_biome_color.LEAVES_SPRUCE] = c_plains_biome_foliage_2
		app.env_color_list[e_biome_color.LEAVES_BIRCH] = c_plains_biome_foliage_2
		value[e_value.ENV_LEAVES_SPRUCE_COLOR] = app.env_color_list[e_biome_color.LEAVES_SPRUCE]
		value[e_value.ENV_LEAVES_BIRCH_COLOR] = app.env_color_list[e_biome_color.LEAVES_BIRCH]
	}
	
	if (load_format < e_project.FORMAT_200_PRE_5)
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_BIOME] = app.env_biome
	
	// Display texture animation speed as a percentage (2.1)
	if (load_format < e_project.FORMAT_CTB_106) // Convert from pre-2.1 arbitrary decimal number
	{
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_TEXTURE_ANI_SPEED] *= 3 // 75% for older projects
	}
	else if (load_format < e_project.FORMAT_210) // Convert from Continuation Build 'fps' display
	{
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_TEXTURE_ANI_SPEED] /= 20
	}
	
	// Fixed sunrise direction + cloud direction (2.1.0)
	if (load_format < e_project.FORMAT_210)
	{
		if (timeline.type = e_tl_type.ENVIRONMENT)
		{
			value[e_value.ENV_SKY_TIME] *= -1
			value[e_value.ENV_SKY_CLOUDS_SPEED] *= -1
			value[e_value.ENV_SKY_CLOUDS_OFFSET_Y] *= -1
		}
	}
}
