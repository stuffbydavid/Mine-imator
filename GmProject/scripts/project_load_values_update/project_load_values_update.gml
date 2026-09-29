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
			
			value[e_value.ENV_GRASS_COLOR] = app.env_grass_color
			value[e_value.ENV_FOLIAGE_COLOR] = app.env_foliage_color
			value[e_value.ENV_DRY_FOLIAGE_COLOR] = app.env_dry_foliage_color
			value[e_value.ENV_WATER_COLOR] = app.env_water_color
			
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
			value[e_value.CAM_BLOOM_RATIO] = max(0, value[e_value.CAM_BLOOM_RATIO])
			value[e_value.CAM_DOF_BLUR_RATIO] = max(0, value[e_value.CAM_DOF_BLUR_RATIO])
		}
		
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_GROUND_SLOT] = app.env_ground_slot
	}
	
	// Old anamorphic ratio was moved into Blade Stretch, anamorphic doesn't rotate with blades (2.1.0)
	if (load_format < e_project.FORMAT_210 && timeline.type = e_tl_type.CAMERA && load_format > e_project.FORMAT_123_PRE_2)
	{
		value[e_value.CAM_BLADE_ANGLE] = -value[e_value.CAM_BLADE_ANGLE]
		value[e_value.CAM_BLADE_STRETCH] = -value[e_value.CAM_DOF_BLUR_RATIO]
		value[e_value.CAM_DOF_BLUR_RATIO] = 0
	}

	// Separated leaf colors for custom biome setting (2.0.0)
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		app.env_leaves_oak_color = app.env_foliage_color
		app.env_leaves_spruce_color = c_plains_biome_foliage_2
		app.env_leaves_birch_color = c_plains_biome_foliage_2
		app.env_leaves_jungle_color = app.env_foliage_color
		app.env_leaves_acacia_color = app.env_foliage_color
		app.env_leaves_dark_oak_color = app.env_foliage_color
		app.env_leaves_mangrove_color = app.env_foliage_color
		
		value[e_value.ENV_LEAVES_OAK_COLOR] = value[e_value.ENV_FOLIAGE_COLOR]
		value[e_value.ENV_LEAVES_SPRUCE_COLOR] = app.env_leaves_spruce_color
		value[e_value.ENV_LEAVES_BIRCH_COLOR] = app.env_leaves_birch_color
		value[e_value.ENV_LEAVES_JUNGLE_COLOR] = value[e_value.ENV_FOLIAGE_COLOR]
		value[e_value.ENV_LEAVES_ACACIA_COLOR] = value[e_value.ENV_FOLIAGE_COLOR]
		value[e_value.ENV_LEAVES_DARK_OAK_COLOR] = value[e_value.ENV_FOLIAGE_COLOR]
		value[e_value.ENV_LEAVES_MANGROVE_COLOR] = value[e_value.ENV_FOLIAGE_COLOR]
	}
	
	if (load_format < e_project.FORMAT_200_PRE_5)
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_BIOME] = app.env_biome
	
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		if (timeline.type = e_tl_type.ENVIRONMENT)
			value[e_value.ENV_SUNLIGHT_STRENGTH] += 1
		
		if (timeline.type = e_tl_type.CAMERA && value[e_value.CAM_SHAKE])
		{
			value[e_value.CAM_SHAKE_MODE] = 1
			value[e_value.CAM_SHAKE_SPEED_X] *= 10
			value[e_value.CAM_SHAKE_SPEED_Y] *= 10
		}
	}
	
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
