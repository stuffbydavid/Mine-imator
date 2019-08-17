/// tab_properties_background()

var capwid;

// Toggle image
tab_control_checkbox()
draw_radiobutton("backgroundshowsky", dx, dy, 0, background_image_show = 0, action_background_image_show)
draw_radiobutton("backgroundshowimage", dx + floor(dw * 0.4), dy, 1, background_image_show = 1, action_background_image_show)
tab_next()

if (background_image_show)
{
	var text, tex;
	
	capwid = text_caption_width("backgroundimage", "backgroundimagetype")
	
	// Background image
	text = text_get("listnone")
	tex = null
	if (background_image != null)
	{
		text = background_image.display_name
		tex = background_image.texture
	}
	tab_control(40)
	draw_button_menu("backgroundimage", e_menu.LIST, dx, dy, dw, 40, background_image, text, action_background_image, tex, null, capwid)
	tab_next()
	
	if (background_image != null)
	{
		// Image type
		tab_control(24)
		draw_button_menu("backgroundimagetype", e_menu.LIST, dx, dy, dw, 24, background_image_type, text_get("backgroundimagetype" + background_image_type), action_background_image_type, null, null, capwid)
		tab_next()
		
		// Background stretch
		if (background_image_type = "image")
		{
			tab_control(24)
			draw_checkbox("backgroundimagestretch", dx, dy + 3, background_image_stretch, action_background_image_stretch)
			tab_next()
		}
		
		// Rotation
		if (background_image_type != "image")
		{
			tab_control_meter()
			draw_meter("backgroundimagerotation", dx, dy, dw, background_image_rotation, 48, 0, 360, 0, 1, tab.background.tbx_background_rotation, action_background_image_rotation)
			tab_next()
		}
		
		// Background box mapped
		if (background_image_type = "box") 
		{
			tab_control(24)
			draw_checkbox("backgroundimageboxmapped", dx, dy + 3, background_image_box_mapped, action_background_image_box_mapped)
			if (background_image_box_mapped)
			{
				var wid = text_max_width("backgroundimagesavemap") + 10;
				if (draw_button_normal("backgroundimagesavemap", dx + dw - wid, dy, wid, 24))
					action_background_image_save_map()
			}
			tab_next()
		}
	}
}
else
{
	var tex;
	capwid = text_caption_width("backgroundskysuntex", "backgroundskymoontex", "backgroundskymoonphase")
	
	// Sun
	tex = test((background_sky_sun_tex.type = e_res_type.PACK), background_sky_sun_tex.sun_texture, background_sky_sun_tex.texture)
	tab_control(40)
	draw_button_menu("backgroundskysuntex", e_menu.LIST, dx, dy, dw, 40, background_sky_sun_tex, background_sky_sun_tex.display_name, action_background_sky_sun_tex, tex, null, capwid)
	tab_next()
	
	// Moon
	if (background_sky_moon_tex.type = e_res_type.PACK && background_sky_moon_tex.ready)
		tex = background_sky_moon_tex.moon_texture[background_sky_moon_phase]
	else
		tex = background_sky_moon_tex.texture
	tab_control(40)
	draw_button_menu("backgroundskymoontex", e_menu.LIST, dx, dy, dw, 40, background_sky_moon_tex, background_sky_moon_tex.display_name, action_background_sky_moon_tex, tex, null, capwid)
	tab_next()
	
	// Moon phase
	if (background_sky_moon_tex.type = e_res_type.PACK && background_sky_moon_tex.ready)
	{
		tab_control(40)
		draw_button_menu("backgroundskymoonphase", e_menu.LIST, dx, dy, dw, 40, background_sky_moon_phase, text_get("backgroundskymoonphase" + string(background_sky_moon_phase + 1)), action_background_sky_moon_phase, background_sky_moon_tex.moon_texture[background_sky_moon_phase], null, capwid)
		tab_next()
	}
}

// Time/rotation
tab_control(120)
draw_wheel_sky("backgroundskytime", dx + floor(dw * 0.25), dy + 60, background_sky_time, -45, action_background_sky_time)
draw_wheel_sky("backgroundskyrotation", dx + floor(dw * 0.75), dy + 60, background_sky_rotation, 0, action_background_sky_rotation)
tab_next()

// Sunlight range/follow camera
tab_control_dragger()
draw_dragger("backgroundsunlightrange", dx, dy, dw * 0.6, background_sunlight_range, background_sunlight_range / 100, 400, world_size, 2000, 10, tab.background.tbx_sunlight_range, action_background_sunlight_range)
draw_checkbox("backgroundsunlightfollow", dx + floor(dw * 0.6), dy, background_sunlight_follow, action_background_sunlight_follow)
tab_next()

// Sunlight strength
tab_control_meter()
draw_meter("backgroundsunlightstrength", dx, dy, dw, round(background_sunlight_strength * 100), 64, 0, 100, 0, 1, tab.background.tbx_sunlight_strength, action_background_sunlight_strength)
tab_next()

// Desaturate night
tab_control_checkbox()
draw_checkbox("backgrounddesaturatenight", dx, dy, background_desaturate_night, action_background_desaturate_night)
tab_next()

// Desaturate amount
if (background_desaturate_night)
{
	tab_control_meter()
	draw_meter("backgrounddesaturatenightamount", dx, dy, dw, round(background_desaturate_night_amount * 100), 64, 0, 100, 0, 1, tab.background.tbx_desaturate_night_amount, action_background_desaturate_night_amount)
	tab_next()
}

// Clouds
tab_control_checkbox_expand()
draw_checkbox_expand("backgroundskycloudsshow", dx, dy, background_sky_clouds_show, action_background_sky_clouds_show, checkbox_expand_background_clouds, action_checkbox_expand_background_clouds)
tab_next()

if (background_sky_clouds_show && checkbox_expand_background_clouds)
{
	dx += 4
	dw -= 4
	
	// Flat clouds
	tab_control_checkbox()
	draw_checkbox("backgroundskycloudsflat", dx, dy, background_sky_clouds_flat, action_background_sky_clouds_flat)
	tab_next()
	
	// 'Story mode' clouds
	tab_control_checkbox()
	draw_checkbox("backgroundskycloudsstorymode", dx, dy, background_sky_clouds_story_mode, action_background_sky_clouds_story_mode)
	tab_next()
	
	capwid = text_caption_width("backgroundskycloudstex", "backgroundskycloudsspeed", "backgroundskycloudsz", "backgroundskycloudssize", "backgroundskycloudsheight")
	
	// Cloud texture
	var tex = test((background_sky_clouds_tex.type = e_res_type.PACK), background_sky_clouds_tex.clouds_texture, background_sky_clouds_tex.texture);
	tab_control(40)
	draw_button_menu("backgroundskycloudstex", e_menu.LIST, dx, dy, dw, 40, background_sky_clouds_tex, background_sky_clouds_tex.display_name, action_background_sky_clouds_tex, tex, null, capwid)
	tab_next()
	
	// Cloud speed
	tab_control_dragger()
	draw_dragger("backgroundskycloudsspeed", dx, dy, dw, background_sky_clouds_speed, 1 / 10, -no_limit, no_limit, 1, 0, tab.background.tbx_sky_clouds_speed, action_background_sky_clouds_speed, capwid)
	tab_next()
	
	// Cloud Z / Y
	tab_control_dragger()
	draw_dragger("backgroundskyclouds" + test(setting_z_is_up, "z", "y"), dx, dy, dw, background_sky_clouds_z, 10, -no_limit, no_limit, 1000, 0, tab.background.tbx_sky_clouds_z, action_background_sky_clouds_z, capwid)
	tab_next()
	
	// Cloud size
	tab_control_dragger()
	draw_dragger("backgroundskycloudssize", dx, dy, dw, background_sky_clouds_size, 5, 16, no_limit, 192, 0, tab.background.tbx_sky_clouds_size, action_background_sky_clouds_size, capwid)
	tab_next()
	
	// Cloud height
	tab_control_dragger()
	draw_dragger("backgroundskycloudsheight", dx, dy, dw, background_sky_clouds_height, 2, 0, no_limit, 64, 0, tab.background.tbx_sky_clouds_height, action_background_sky_clouds_height, capwid)
	tab_next()
	
	// Cloud offset
	tab_control_dragger()
	draw_dragger("backgroundskycloudsoffset", dx, dy, dw, background_sky_clouds_offset, 10, -no_limit, no_limit, 0, 1, tab.background.tbx_sky_clouds_offset, action_background_sky_clouds_offset, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Ground
capwid = text_caption_width("backgroundground", "backgroundgroundtex")

tab_control_checkbox_expand()
draw_checkbox_expand("backgroundgroundshow", dx, dy, background_ground_show, action_background_ground_show, checkbox_expand_background_ground, action_checkbox_expand_background_ground)
tab_next()

if (background_ground_show && checkbox_expand_background_ground)
{
	dx += 4
	dw -= 4
	
	var wid, res;
	wid = text_caption_width("backgroundgroundchange")
	res = background_ground_tex
	if (!res.ready)
		res = mc_res
	
	// Change ground
	tab_control(24)
	draw_label(text_get("backgroundground") + ":", dx, dy + 12, fa_left, fa_middle)
	if (background_ground_ani)
		draw_texture_slot(res.block_sheet_ani_texture[block_texture_get_frame()], background_ground_slot - ds_list_size(mc_assets.block_texture_list), dx + capwid, dy + 4, 16, 16, block_sheet_ani_width, block_sheet_ani_height, block_texture_get_blend(background_ground_name, res))
	else
		draw_texture_slot(res.block_sheet_texture, background_ground_slot, dx + capwid, dy + 4, 16, 16, block_sheet_width, block_sheet_height, block_texture_get_blend(background_ground_name, res))
	
	if (draw_button_normal("backgroundgroundchange", dx + dw - wid, dy, wid, 24, e_button.TEXT, ground_editor.show, true, true))
		tab_toggle(ground_editor)
	tab_next()
	
	// Ground texture
	tab_control(40)
	draw_button_menu("backgroundgroundtex", e_menu.LIST, dx, dy, dw, 40, background_ground_tex, background_ground_tex.display_name, action_background_ground_tex, background_ground_tex.block_preview_texture, null, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Biome
if (background_biome.name != "custom" && ds_list_valid(background_biome.biome_variants))
	capwid = text_caption_width("backgroundbiome", "backgroundbiomevariant")
else
	capwid = text_caption_width("backgroundbiome")

tab_control(24)
draw_button_menu("backgroundbiome", e_menu.LIST, dx, dy, dw, 24, background_biome, minecraft_asset_get_name("biome", background_biome.name), action_background_biome, null, null, capwid)
tab_next()

if (background_biome.name != "custom" && ds_list_valid(background_biome.biome_variants))
{
	// Biome variant
	tab_control(24)
	draw_button_menu("backgroundbiomevariant", e_menu.LIST, dx, dy, dw, 24, background_biome.selected_variant, minecraft_asset_get_name("biome", background_biome.biome_variants[|background_biome.selected_variant].name), action_background_biome_variant, null, null, capwid)
	tab_next()
}

// Background colors
var custombiome = (background_biome.name = "custom")
var wid = test(custombiome, floor(dw / 2) - 4, dw);
var pxpad = 8 * custombiome;

tab_control(20)
draw_label(text_get("backgroundcolor") + ":", dx, dy, fa_left, fa_top)
tab_next()

// Sky & Clouds color
tab_control_color()
draw_button_color("backgroundskycolor", dx, dy, wid, background_sky_color, c_sky, false, action_background_sky_color)

if (!custombiome)
{
	tab_next()
	tab_control_color()
}

draw_button_color("backgroundskycloudscolor", dx + (wid + pxpad) * custombiome, dy, wid, background_sky_clouds_color, c_clouds, false, action_background_sky_clouds_color)
tab_next()

// Sun light & Ambient color
tab_control_color()
draw_button_color("backgroundsunlightcolor", dx, dy, wid, background_sunlight_color, c_sunlight, false, action_background_sunlight_color)

if (!custombiome)
{
	tab_next()
	tab_control_color()
}

draw_button_color("backgroundambientcolor", dx + (wid + pxpad) * custombiome, dy, wid, background_ambient_color, c_ambient, false, action_background_ambient_color)
tab_next()

// Night color
tab_control_color()
draw_button_color("backgroundnightcolor", dx, dy, wid, background_night_color, c_night, false, action_background_night_color)

// Biome colors
if (custombiome)
{
	// Grass color
	draw_button_color("backgroundgrasscolor", dx + wid + 8, dy, wid, background_grass_color, c_plains_biome_grass, false, action_background_grass_color)
	tab_next()

	// Foliage & Water color
	tab_control_color()
	draw_button_color("backgroundfoliagecolor", dx, dy, wid, background_foliage_color, c_plains_biome_foliage, false, action_background_foliage_color)
	draw_button_color("backgroundwatercolor", dx + wid + 8, dy, wid, background_water_color, c_plains_biome_water, false, action_background_water_color)
	tab_next()
}
else
	tab_next()

// Show fog
tab_control_checkbox_expand()
draw_checkbox_expand("backgroundfog", dx, dy, background_fog_show, action_background_fog_show, checkbox_expand_background_fog, action_checkbox_expand_background_fog)
tab_next()

if (background_fog_show && checkbox_expand_background_fog)
{
	dx += 4
	dw -= 4
	
	// Sky fog
	tab_control_checkbox()
	draw_checkbox("backgroundfogsky", dx, dy, background_fog_sky, action_background_fog_sky)
	tab_next()
	
	// Custom color && Custom object fog color
	tab_control_checkbox()
	draw_checkbox("backgroundfogcolorcustom", dx, dy, background_fog_color_custom, action_background_fog_color_custom)
	draw_checkbox("backgroundfogobjectcolorcustom", dx + floor(dw * 0.5), dy, background_fog_object_color_custom, action_background_fog_object_color_custom)
	tab_next()
	
	// Fog color
	if (background_fog_color_custom)
	{
		tab_control_color()
		draw_button_color("backgroundfogcolor", dx, dy, dw, background_fog_color, c_sky, false, action_background_fog_color)
		tab_next()
	}
	
	// Object Fog color
	if (background_fog_object_color_custom)
	{
		tab_control_color()
		draw_button_color("backgroundfogobjectcolor", dx, dy, dw, background_fog_object_color, c_sky, false, action_background_fog_object_color)
		tab_next()
	}
	
	capwid = text_caption_width("backgroundfogdistance", "backgroundfogsize")
	
	// Fog distance
	tab_control_dragger()
	draw_dragger("backgroundfogdistance", dx, dy, dw, background_fog_distance, background_fog_distance / 100, 10, world_size, 10000, 10, tab.background.tbx_fog_distance, action_background_fog_distance, capwid)
	tab_next()
	
	// Fog size
	tab_control_dragger()
	draw_dragger("backgroundfogsize", dx, dy, dw, background_fog_size, background_fog_size / 100, 10, world_size, 2000, 10, tab.background.tbx_fog_size, action_background_fog_size, capwid)
	tab_next()
	
	// Fog height
	tab_control_dragger()
	draw_dragger("backgroundfogheight", dx, dy, dw, background_fog_height, background_fog_height / 100, 10, 2000, 1000, 10, tab.background.tbx_fog_height, action_background_fog_height, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Wind
tab_control_checkbox_expand()
draw_checkbox_expand("backgroundwind", dx, dy, background_wind, action_background_wind, checkbox_expand_background_wind, action_checkbox_expand_background_wind)
tab_next()

if (background_wind && checkbox_expand_background_wind)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("backgroundwindstrength", "backgroundwindamount")
	
	// Wind strength
	tab_control_meter()
	draw_meter("backgroundwindspeed", dx, dy, dw, round(background_wind_speed * 100), 64, 0, 100, 10, 1, tab.background.tbx_wind_speed, action_background_wind_speed, capwid)
	tab_next()
	
	// Wind amount
	tab_control_meter()
	draw_meter("backgroundwindstrength", dx, dy, dw, background_wind_strength, 64, 0, 8, 0.5, 0.05, tab.background.tbx_wind_strength, action_background_wind_strength, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Fast graphics
tab_control_checkbox()
draw_checkbox("backgroundopaqueleaves", dx, dy, background_opaque_leaves, action_background_opaque_leaves)
tab_next()

// Animation speed
tab_control_dragger()
draw_dragger("backgroundtextureanimationspeed", dx, dy, dw, background_texture_animation_speed, 1 / 100, 0, no_limit, 0.25, 0, tab.background.tbx_texture_animation_speed, action_background_texture_animation_speed)
tab_next()
