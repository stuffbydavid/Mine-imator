/// project_load_update_values()
/// @desc Updates values in keyframes if/because they were not animatable in previous versions

if (load_format < e_project.FORMAT_120_PRE_3)
{
	if (timeline.type = e_tl_type.BACKGROUND)
	{
		value[e_value.BG_IMAGE_SHOW] = app.background_image_show
		
		value[e_value.BG_SUNLIGHT_RANGE] = app.background_sunlight_range
		value[e_value.BG_SUNLIGHT_FOLLOW] = app.background_sunlight_follow
		value[e_value.BG_SUNLIGHT_STRENGTH] = app.background_sunlight_strength
		
		value[e_value.BG_SKY_CLOUDS_SHOW] = app.background_sky_clouds_show
		value[e_value.BG_SKY_CLOUDS_Z] = app.background_sky_clouds_z
		
		value[e_value.BG_GROUND_SHOW] = app.background_ground_show
		
		value[e_value.BG_GRASS_COLOR] = app.background_grass_color
		value[e_value.BG_FOLIAGE_COLOR] = app.background_foliage_color
		value[e_value.BG_WATER_COLOR] = app.background_water_color
		
		value[e_value.BG_FOG_SHOW] = app.background_fog_show
		value[e_value.BG_FOG_SKY] = app.background_fog_sky
		value[e_value.BG_FOG_CUSTOM_COLOR] = app.background_fog_color_custom
		value[e_value.BG_FOG_CUSTOM_OBJECT_COLOR] = app.background_fog_object_color_custom
		
		value[e_value.BG_WIND] = app.background_wind
	}
}