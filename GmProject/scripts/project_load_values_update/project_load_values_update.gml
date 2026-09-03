/// project_load_update_values()
/// @desc Updates values from previous versions

function project_load_values_update()
{
	// More background values can be keyframed (1.2.0)
	if (load_format < e_project.FORMAT_120_PRE_3)
	{
		if (timeline.type = e_tl_type.BACKGROUND)
		{
			value[e_value.BG_IMAGE_SHOW] = app.background_image_show
			
			value[e_value.BG_SUNLIGHT_STRENGTH] = app.background_sunlight_strength
			
			value[e_value.BG_SKY_CLOUDS_SHOW] = app.background_sky_clouds_show
			value[e_value.BG_SKY_CLOUDS_HEIGHT] = app.background_sky_clouds_height
			
			value[e_value.BG_GROUND_SHOW] = app.background_ground_show
			
			value[e_value.BG_GRASS_COLOR] = app.background_grass_color
			value[e_value.BG_FOLIAGE_COLOR] = app.background_foliage_color
			value[e_value.BG_DRY_FOLIAGE_COLOR] = app.background_dry_foliage_color
			value[e_value.BG_WATER_COLOR] = app.background_water_color
			
			value[e_value.BG_FOG_SHOW] = app.background_fog_show
			value[e_value.BG_FOG_SKY] = app.background_fog_sky
			value[e_value.BG_FOG_CUSTOM_COLOR] = app.background_fog_color_custom
			value[e_value.BG_FOG_CUSTOM_OBJECT_COLOR] = app.background_fog_custom_object_color
		
			value[e_value.BG_WIND] = app.background_wind
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
		
		if (timeline.type = e_tl_type.BACKGROUND)
			value[e_value.BG_GROUND_SLOT] = app.background_ground_slot
	}
	
	// Separated leaf colors for custom biome setting (2.0.0)
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		app.background_leaves_oak_color = app.background_foliage_color
		app.background_leaves_spruce_color = c_plains_biome_foliage_2
		app.background_leaves_birch_color = c_plains_biome_foliage_2
		app.background_leaves_jungle_color = app.background_foliage_color
		app.background_leaves_acacia_color = app.background_foliage_color
		app.background_leaves_dark_oak_color = app.background_foliage_color
		app.background_leaves_mangrove_color = app.background_foliage_color
		
		value[e_value.BG_LEAVES_OAK_COLOR] = value[e_value.BG_FOLIAGE_COLOR]
		value[e_value.BG_LEAVES_SPRUCE_COLOR] = app.background_leaves_spruce_color
		value[e_value.BG_LEAVES_BIRCH_COLOR] = app.background_leaves_birch_color
		value[e_value.BG_LEAVES_JUNGLE_COLOR] = value[e_value.BG_FOLIAGE_COLOR]
		value[e_value.BG_LEAVES_ACACIA_COLOR] = value[e_value.BG_FOLIAGE_COLOR]
		value[e_value.BG_LEAVES_DARK_OAK_COLOR] = value[e_value.BG_FOLIAGE_COLOR]
		value[e_value.BG_LEAVES_MANGROVE_COLOR] = value[e_value.BG_FOLIAGE_COLOR]
	}
	
	if (load_format < e_project.FORMAT_200_PRE_5)
		if (timeline.type = e_tl_type.BACKGROUND)
			value[e_value.BG_BIOME] = app.background_biome
	
	if (load_format < e_project.FORMAT_200_PRE_5)
	{
		if (timeline.type = e_tl_type.BACKGROUND)
			value[e_value.BG_SUNLIGHT_STRENGTH] += 1
		
		if (timeline.type = e_tl_type.CAMERA && value[e_value.CAM_SHAKE])
		{
			value[e_value.CAM_SHAKE_MODE] = 1
			value[e_value.CAM_SHAKE_SPEED_X] *= 10
			value[e_value.CAM_SHAKE_SPEED_Y] *= 10
		}
	}
}
