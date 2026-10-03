function tab_properties_environment()
{
	// Time/rotation
	if (window_compact || panel_compact)
	{
		tab_control_dragger()
		draw_dragger_sky("environment/sky/time", dx, dy, env_sky_time, 45, action_env_sky_time, tab.environment.tbx_sky_time, true)
		tab_next()
		
		tab_control_dragger()
		draw_dragger_sky("environment/sky/rotation", dx, dy, env_sky_rotation, -45, action_env_sky_rotation, tab.environment.tbx_sky_rotation, false)
		tab_next()
	}
	else
	{
		tab_control(120)
		draw_wheel_sky("environment/sky/time", dx + floor(dw * 0.25), dy + 60, env_sky_time, 45, action_env_sky_time, tab.environment.tbx_sky_time, true)
		draw_wheel_sky("environment/sky/rotation", dx + floor(dw * 0.75), dy + 60, env_sky_rotation, -45, action_env_sky_rotation, tab.environment.tbx_sky_rotation, false)
		tab_next()
	}
	
	// Dimension
	tab_control_togglebutton()
	togglebutton_add("environment/dimension/overworld", null, "overworld", env_dimension = "overworld", action_env_dimension)
	togglebutton_add("environment/dimension/the_nether", null, "the_nether", env_dimension = "the_nether", action_env_dimension)
	togglebutton_add("environment/dimension/the_end", null, "the_end", env_dimension = "the_end", action_env_dimension)
	draw_togglebutton("environment/dimension", dx, dy)
	tab_next()
	
	// Biome
	tab_control_menu()
	draw_button_menu("environment/biome", e_menu.BIOME, dx, dy, dw, 24, env_biome, minecraft_asset_get_name("biome", env_biome), action_env_biome)
	tab_next()

	if (env_biome = "custom")
	{
		tab_control_switch()
		draw_button_collapse("environment/biome", collapse_map[?"environment/biome"], null, true, "environment/custom_biome")
		tab_next()

		if (collapse_map[?"environment/biome"])
		{
			tab_collapse_start()

			// Biome colors
			dy += 20
			draw_label(text_get("environment/biome_colors") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
			dy += 8

			tab_set_columns(true, floor(content_width/150))

			// Grass
			tab_control_color()
			draw_button_color("environment/grass_color", dx, dy, dw, env_grass_color, c_plains_biome_grass, false, action_env_grass_color)
			tab_next()

			// Foliage
			tab_control_color()
			draw_button_color("environment/foliage_color", dx, dy, dw, env_foliage_color, c_plains_biome_foliage, false, action_env_foliage_color)
			tab_next()

			// Dry foliage
			tab_control_color()
			draw_button_color("environment/dry_foliage_color", dx, dy, dw, env_dry_foliage_color, c_plains_biome_dry_foliage, false, action_env_dry_foliage_color)
			tab_next()

			// Water
			tab_control_color()
			draw_button_color("environment/water_color", dx, dy, dw, env_water_color, c_plains_biome_water, false, action_env_water_color)
			tab_next()

			tab_set_columns(false)

			dy += 20
			draw_label(text_get("environment/leaf_colors") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
			dy += 8

			tab_set_columns(true, floor(content_width/150))

			// Oak leaves
			tab_control_color()
			draw_button_color("environment/leaves/oak_color", dx, dy, dw, env_leaves_oak_color, c_plains_biome_foliage, false, action_env_leaves_oak_color)
			tab_next()

			// Spruce leaves
			tab_control_color()
			draw_button_color("environment/leaves/spruce_color", dx, dy, dw, env_leaves_spruce_color, c_plains_biome_foliage_2, false, action_env_leaves_spruce_color)
			tab_next()

			// Birch
			tab_control_color()
			draw_button_color("environment/leaves/birch_color", dx, dy, dw, env_leaves_birch_color, c_plains_biome_foliage_2, false, action_env_leaves_birch_color)
			tab_next()

			// Jungle
			tab_control_color()
			draw_button_color("environment/leaves/jungle_color", dx, dy, dw, env_leaves_jungle_color, c_plains_biome_foliage, false, action_env_leaves_jungle_color)
			tab_next()

			// Acacia
			tab_control_color()
			draw_button_color("environment/leaves/acacia_color", dx, dy, dw, env_leaves_acacia_color, c_plains_biome_foliage, false, action_env_leaves_acacia_color)
			tab_next()

			// Dark oak
			tab_control_color()
			draw_button_color("environment/leaves/dark_oak_color", dx, dy, dw, env_leaves_dark_oak_color, c_plains_biome_foliage, false, action_env_leaves_dark_oak_color)
			tab_next()

			// Mangrove
			tab_control_color()
			draw_button_color("environment/leaves/mangrove_color", dx, dy, dw, env_leaves_mangrove_color, c_plains_biome_foliage, false, action_env_leaves_mangrove_color)
			tab_next()

			tab_set_columns(false)
			tab_collapse_end()
		}
	}

	// Sky properties
	tab_control_switch()
	draw_button_collapse("environment/sky", collapse_map[?"environment/sky"], null, true, "environment/sky_background")
	tab_next()
	
	if (collapse_map[?"environment/sky"])
	{
		tab_collapse_start()
		
		// Toggle image
		tab_control_togglebutton()
		togglebutton_add("environment/sky_minecraft", null, 0, env_background_image_show = 0, action_env_background_image_show)
		togglebutton_add("environment/sky_custom", null, 1, env_background_image_show = 1, action_env_background_image_show)
		draw_togglebutton("environment/sky", dx, dy)
		tab_next()
		
		if (env_background_image_show)
		{
			var tex;
			content_capwid = text_caption_width("environment/image", "environment/image/type")
			
			// Background image
			content_text = text_get("list/none")
			tex = null
			if (env_background_image != null)
			{
				content_text = env_background_image.display_name
				tex = env_background_image.texture
			}
			
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/image", e_menu.LIST, dx, dy, dw, ui_large_height, env_background_image, content_text, action_env_background_image, false, tex)
			tab_next()
			
			if (env_background_image != null)
			{
				// Image type
				tab_control_menu()
				draw_button_menu("environment/image/type", e_menu.LIST, dx, dy, dw, 24, env_background_image_type, text_get("environment/image/type_" + env_background_image_type), action_env_background_image_type)
				tab_next()
				
				// Background stretch
				if (env_background_image_type = "image")
				{
					tab_control_switch()
					draw_switch("environment/image/stretch", dx, dy, env_background_image_stretch, action_env_background_image_stretch)
					tab_next()
				}
				
				// Rotation
				if (env_background_image_type != "image")
				{
					tab_control_dragger()
					draw_dragger("environment/image/rotation", dx, dy, dragger_width, env_background_image_rotation, .1, -no_limit, no_limit, 0, 1, tab.environment.tbx_background_image_rotation, action_env_background_image_rotation)
					tab_next()
				}
				
				// Background box mapped
				if (env_background_image_type = "box") 
				{
					tab_control_switch()
					draw_switch("environment/image/box_mapped", dx, dy, env_background_image_box_mapped, action_env_background_image_box_mapped)
					tab_next()
					
					if (env_background_image_box_mapped)
					{
						tab_control_button_label()
						
						if (draw_button_label("environment/image/save_map", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
							action_env_background_image_save_map()
						
						tab_next()
					}
				}
			}
		}
		else
		{
			var tex;
			content_capwid = text_caption_width("environment/sky/sun_tex", "environment/sky/moon_tex", "environment/sky/moon_phase")
			
			// Sun
			var sunres = res_eval(env_sky_sun_tex);
			tex = ((sunres.type = e_res_type.PACK) ? sunres.sun_texture : sunres.texture)
			
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/sky/sun_tex", e_menu.LIST, dx, dy, dw, ui_large_height, env_sky_sun_tex, sunres.display_name, action_env_sky_sun_tex, false, tex)
			tab_next()
			
			// Sun angle
			tab_control_dragger()
			draw_dragger("environment/sky/sun_angle", dx, dy, dragger_width, env_sky_sun_angle, 0.1, -no_limit, no_limit, 0, 1, tab.environment.tbx_sky_sun_angle, action_env_sky_sun_angle)
			tab_next()
			
			// Sun scale
			tab_control_dragger()
			draw_dragger("environment/sky/sun_scale", dx, dy, dragger_width, round(env_sky_sun_scale * 100), max(0.1, ceil(env_sky_sun_scale / 5) / 10), 0, 10000, 100, 1, tab.environment.tbx_sky_sun_scale, action_env_sky_sun_scale)
			tab_next()
		}

		if (setting_advanced_mode)
		{
			// Sunlight angle
			tab_control_dragger()
			draw_dragger("environment/sunlight_angle", dx, dy, dragger_width, env_sunlight_angle, .05, 0, no_limit, .526, .001, tab.environment.tbx_sunlight_angle, action_env_sunlight_angle, null, true, false, "environment/sunlight_angle_tip")
			tab_next()
		}

		// Sunlight strength
		tab_control_dragger()
		draw_dragger("environment/sunlight_strength", dx, dy, dragger_width, round(env_sunlight_strength * 100), 0.1, 0, no_limit, 100, 1, tab.environment.tbx_sunlight_strength, action_env_sunlight_strength)
		tab_next()

		// Sunlight specular strength
		tab_control_dragger()
		draw_dragger("environment/sunlight_specular_strength", dx, dy, dragger_width, round(env_sunlight_specular_strength * 100), 0.1, 0, no_limit, 100, 1, tab.environment.tbx_sunlight_specular_strength, action_env_sunlight_specular_strength)
		tab_next()

		dy += 8

		if (!env_background_image_show)
		{
			var moonres, moontex;

			// Moon
			moonres = res_eval(env_sky_moon_tex)
			if (moonres.type = e_res_type.PACK && moonres.ready)
				moontex = moonres.moon_textures[env_sky_moon_phase]
			else
				moontex = moonres.texture
			
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/sky/moon_tex", e_menu.LIST, dx, dy, dw, ui_large_height, env_sky_moon_tex, moonres.display_name, action_env_sky_moon_tex, false, moontex)
			tab_next()
			
			// Moon phase
			if (moonres.type = e_res_type.PACK && moonres.ready)
			{
				tab_control_menu(ui_large_height)
				draw_button_menu("environment/sky/moon_phase", e_menu.LIST, dx, dy, dw, ui_large_height, env_sky_moon_phase, text_get("environment/sky/moon_phase/" + string(env_sky_moon_phase + 1)), action_env_sky_moon_phase, false, moonres.moon_textures[env_sky_moon_phase])
				tab_next()
			}
			
			// Moon angle
			tab_control_dragger()
			draw_dragger("environment/sky/moon_angle", dx, dy, dragger_width, env_sky_moon_angle, 0.1, -no_limit, no_limit, 0, 1, tab.environment.tbx_sky_moon_angle, action_env_sky_moon_angle)
			tab_next()
			
			// Moon scale
			tab_control_dragger()
			draw_dragger("environment/sky/moon_scale", dx, dy, dragger_width, round(env_sky_moon_scale * 100), max(0.1, ceil(env_sky_moon_scale / 5) / 10), 0, 10000, 100, 1, tab.environment.tbx_sky_moon_scale, action_env_sky_moon_scale)
			tab_next()
		}

		// Day colors
		dy += 20
		draw_label(text_get("environment/day_scene_colors") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
		dy += 8

		tab_set_columns(true, floor(content_width/150))

		// Sky
		var skydefault, skybiome;
		skydefault = c_sky_overworld
		if (env_dimension = "the_nether")
			skydefault = c_sky_the_nether
		else if (env_dimension = "the_end")
			skydefault = c_sky_the_end
		
		skybiome = find_biome(env_biome)
		if (skybiome != null && skybiome.sky_enabled)
			skydefault = skybiome.sky_color
		
		tab_control_color()
		draw_button_color("environment/sky_color", dx, dy, dw, env_sky_color, skydefault, false, action_env_sky_color)
		tab_next()

		// Clouds
		tab_control_color()
		draw_button_color("environment/sky_clouds_color", dx, dy, dw, env_sky_clouds_color, c_clouds, false, action_env_sky_clouds_color)
		tab_next()

		// Sun light
		tab_control_color()
		draw_button_color("environment/sunlight_color", dx, dy, dw, env_sunlight_color, c_sunlight, false, action_env_sunlight_color)
		tab_next()

		// Ambient
		tab_control_color()
		draw_button_color("environment/ambient_color", dx, dy, dw, env_ambient_color, c_ambient, false, action_env_ambient_color)
		tab_next()

		tab_set_columns(false)

		// Night colors
		dy += 20
		draw_label(text_get("environment/night_scene_colors") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
		dy += 8

		tab_set_columns(true, floor(content_width/150))

		// Sky
		tab_control_color()
		draw_button_color("environment/night_sky_color", dx, dy, dw, env_night_sky_color, c_night_sky, false, action_env_night_sky_color)
		tab_next()

		// Clouds
		tab_control_color()
		draw_button_color("environment/night_sky_clouds_color", dx, dy, dw, env_night_sky_clouds_color, c_night_clouds, false, action_env_night_sky_clouds_color)
		tab_next()

		// Stars
		tab_control_color()
		draw_button_color("environment/night_sky_stars_color", dx, dy, dw, env_night_sky_stars_color, c_stars, false, action_env_night_sky_stars_color)
		tab_next()

		// Ambient
		tab_control_color()
		draw_button_color("environment/night_color", dx, dy, dw, env_night_color, c_night, false, action_env_night_color)
		tab_next()

		tab_set_columns(false)

		// Brightness
		tab_control_dragger()
		draw_dragger("environment/brightness", dx, dy, dragger_width, round(env_brightness * 100), .5, 0, no_limit, 100, 1, tab.environment.tbx_brightness, action_env_brightness)
		tab_next()

		// Twilight
		if (setting_advanced_mode)
		{
			tab_control_switch()
			draw_switch("environment/twilight", dx, dy, env_twilight, action_env_twilight, "environment/twilight_tip")
			tab_next()
		}
		
		tab_collapse_end()
	}
	
	// Clouds
	tab_control_switch()
	draw_button_collapse("environment/clouds", collapse_map[?"environment/clouds"], action_env_sky_clouds_show, env_sky_clouds_show, "environment/sky/clouds_show")
	tab_next()
	
	if (env_sky_clouds_show && collapse_map[?"environment/clouds"])
	{
		tab_collapse_start()
		
		// Clouds mode
		tab_control_togglebutton()
		togglebutton_add("environment/sky/clouds/normal", null, "normal", env_sky_clouds_mode = "normal", action_env_sky_clouds_mode)
		togglebutton_add("environment/sky/clouds/faded", null, "faded", env_sky_clouds_mode = "faded", action_env_sky_clouds_mode)
		togglebutton_add("environment/sky/clouds/flat", null, "flat", env_sky_clouds_mode = "flat", action_env_sky_clouds_mode)
		draw_togglebutton("environment/sky/clouds/mode", dx, dy, true, true)
		tab_next()
		
		// Advanced mode only
		if (setting_advanced_mode)
		{
			// Cloud texture
			var cloudres, tex;
			cloudres = res_eval(env_sky_clouds_tex)
			tex = ((cloudres.type = e_res_type.PACK) ? cloudres.clouds_texture : cloudres.texture)
			
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/sky/clouds/tex", e_menu.LIST, dx, dy, dw, ui_large_height, env_sky_clouds_tex, cloudres.display_name, action_env_sky_clouds_tex, false, tex)
			tab_next()
			
			// Cloud speed
			tab_control_dragger()
			draw_dragger("environment/sky/clouds/speed", dx, dy, dragger_width, round(env_sky_clouds_speed * 100), 0.1, -no_limit, no_limit, 100, 0, tab.environment.tbx_sky_clouds_speed, action_env_sky_clouds_speed)
			tab_next()
			
			// Cloud offset
			//axis_edit = X
			//textfield_group_add("environment/sky/clouds/offset_x", env_sky_clouds_offset_x, 0, action_env_sky_clouds_offset_x, axis_edit, tab.transform.tbx_sky_clouds_offset_x, null, 10)
			if (setting_z_is_up)
			{
				axis_edit = Y
				textfield_group_add("environment/sky/clouds/offset_y", env_sky_clouds_offset_y, 0, action_env_sky_clouds_offset_y, axis_edit, tab.environment.tbx_sky_clouds_offset_y, null, 10)
			}
			axis_edit = Z
			textfield_group_add("environment/sky/clouds/offset_" + (setting_z_is_up ? "z" : "y"), env_sky_clouds_offset_z, 1024, action_env_sky_clouds_offset_z, axis_edit, tab.environment.tbx_sky_clouds_offset_z, null, 10)
			if (!setting_z_is_up)
			{
				axis_edit = Y
				textfield_group_add("environment/sky/clouds/offset_z", env_sky_clouds_offset_y, 0, action_env_sky_clouds_offset_y, axis_edit, tab.environment.tbx_sky_clouds_offset_y, null, 10)
			}
			
			tab_control_textfield_group(true)
			draw_textfield_group("environment/sky/clouds/offset", dx, dy, dw, null, -no_limit, no_limit, 1, true, true, 1)
			tab_next()
			
			draw_divide(dx, dy, dw)
			dy += 12
			
			// Cloud size
			//axis_edit = X
			//textfield_group_add("environment/sky/clouds/sizex", env_sky_clouds_size_x, 0, action_env_sky_clouds_size_x, axis_edit, tab.transform.tbx_sky_clouds_size_x, null, 10)
			//axis_edit = (setting_z_is_up ? Y : Z)
			//textfield_group_add("environment/sky/clouds/size" + (setting_z_is_up ? "y" : "z")), env_sky_clouds_size_y, 192, action_env_sky_clouds_size_y, axis_edit, tab.environment.tbx_sky_clouds_size_y, null, 2, 1, no_limit)
			if (setting_z_is_up)
			{
				axis_edit = Y
				textfield_group_add("environment/sky/clouds/size_xy", env_sky_clouds_size_xy, 192, action_env_sky_clouds_size_xy, axis_edit, tab.environment.tbx_sky_clouds_size_xy, null, 2, 1, no_limit)
			}
			axis_edit = Z
			textfield_group_add("environment/sky/clouds/size_" + (setting_z_is_up ? "z" : "y"), env_sky_clouds_size_z, 64, action_env_sky_clouds_size_z, axis_edit, tab.environment.tbx_sky_clouds_size_z, null, 2, 0, no_limit)
			if (!setting_z_is_up)
			{
				axis_edit = Y
				textfield_group_add("environment/sky/clouds/sizexz", env_sky_clouds_size_xy, 192, action_env_sky_clouds_size_xy, axis_edit, tab.environment.tbx_sky_clouds_size_xy, null, 2, 1, no_limit)
			}
			
			tab_control_textfield_group(true)
			draw_textfield_group("environment/sky/clouds/size", dx, dy, dw, null, -no_limit, no_limit, 1, true, true, 1)
			tab_next()
		}
		
		tab_collapse_end()
	}
	
	// Ground
	tab_control_switch()
	draw_button_collapse("environment/ground", collapse_map[?"environment/ground"], action_env_ground_show, env_ground_show, "environment/ground_show")
	tab_next()
	
	content_capwid = text_caption_width("environment/ground", "environment/ground_tex")
	
	if (env_ground_show && collapse_map[?"environment/ground"])
	{
		tab_collapse_start()
		
		var wid, res;
		res = res_eval(env_ground_tex)
		
		// Change ground
		tab_control(24)
		
		draw_set_font(font_label)
		wid = string_width(text_get("environment/ground") + ":")
		
		draw_label(text_get("environment/ground") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		
		draw_box(dx + wid + 16, dy + 4, 20, 20, false, c_level_bottom, 1)
		
		var decodedslot, sheet, slot;
		decodedslot = minecraft_assets_block_texture_picker_slot_decode(env_ground_slot)
		sheet = decodedslot[0]
		slot = decodedslot[1]
		
		if (sheet >= 0 && res.block_sheet_texture[sheet] = null)
			res = mc_res
		
		if (sheet = e_block_sheet.ANIMATED)
			draw_texture_slot(res.block_sheet_texture[sheet][block_texture_get_frame(true)], slot, dx + wid + 18, dy + 6, 16, 16, minecraft_block_sheet_size[sheet][X], minecraft_block_sheet_size[sheet][Y], block_texture_get_blend(env_ground_name, res))
		else if (sheet >= 0)
			draw_texture_slot(res.block_sheet_texture[sheet], slot, dx + wid + 18, dy + 6, 16, 16, minecraft_block_sheet_size[sheet][X], minecraft_block_sheet_size[sheet][Y], block_texture_get_blend(env_ground_name, res))
		
		if (sheet >= 0)
			tip_set(minecraft_texture_get_name(env_ground_name), dx + wid + 16, dy + 4, 20, 20)
		
		if (draw_button_icon("environment/ground_change", dx + dw - 24, dy, 24, 24, ground_editor.show, icons.PENCIL, null, false, "tooltip/change_ground"))
			tab_toggle(ground_editor)
		
		tab_next()
		
		// Ground texture
		var groundname = res_eval(env_ground_tex).display_name;
		tab_control_menu(ui_large_height)
		draw_button_menu("environment/ground_tex", e_menu.LIST, dx, dy, dw, ui_large_height, env_ground_tex, groundname, action_env_ground_tex, false, res_eval(env_ground_tex).block_preview_texture)
		tab_next()
		
		if (project_render_material_maps)
		{
			// Ground texture (material)
			var groundmaterialname = res_eval(env_ground_tex_material).display_name;
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/ground_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, env_ground_tex_material, groundmaterialname, action_env_ground_tex_material, false, res_eval(env_ground_tex_material).block_preview_texture)
			tab_next()
			
			// Ground texture (normal)
			var groundnormalname = res_eval(env_ground_tex_normal).display_name;
			tab_control_menu(ui_large_height)
			draw_button_menu("environment/ground_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, env_ground_tex_normal, groundnormalname, action_env_ground_tex_normal, false, res_eval(env_ground_tex_normal).block_preview_texture)
			tab_next()
		}
		
		tab_collapse_end()
	}
	
	// Show fog
	tab_control_switch()
	draw_button_collapse("environment/fog", collapse_map[?"environment/fog"], action_env_fog_show, env_fog_show, "environment/fog")
	tab_next()
	
	if (env_fog_show && collapse_map[?"environment/fog"])
	{
		tab_collapse_start()
		
		// Sky fog
		tab_control_switch()
		draw_switch("environment/fog/sky", dx, dy, env_fog_sky, action_env_fog_sky)
		tab_next()
		
		// Custom color
		tab_control_switch()
		draw_switch("environment/fog/color_custom", dx, dy, env_fog_color_custom, action_env_fog_color_custom)
		tab_next()
		
		// Fog color
		if (env_fog_color_custom)
		{
			tab_control_color()
			draw_button_color("environment/fog/color", dx, dy, dw, env_fog_color, c_sky_overworld, false, action_env_fog_color)
			tab_next()
		}
		
		// Custom object fog color
		tab_control_switch()
		draw_switch("environment/fog/custom_object_color", dx, dy, env_fog_custom_object_color, action_env_fog_custom_object_color)
		tab_next()
		
		// Fog color
		if (env_fog_custom_object_color)
		{
			tab_control_color()
			draw_button_color("environment/fog/object_color", dx, dy, dw, env_fog_object_color, c_sky_overworld, false, action_env_fog_object_color)
			tab_next()
		}
		
		// Fog distance
		var fogdefault = (env_dimension = "overworld" ? fog_far : fog_near);
		tab_control_dragger()
		draw_dragger("environment/fog/distance", dx, dy, dragger_width, env_fog_distance, env_fog_distance / 100, 10, project_render_distance, fogdefault, 10, tab.environment.tbx_fog_distance, action_env_fog_distance)
		tab_next()
		
		// Fog size
		tab_control_dragger()
		draw_dragger("environment/fog/size", dx, dy, dragger_width, env_fog_size, env_fog_size / 100, 10, project_render_distance, fog_size, 10, tab.environment.tbx_fog_size, action_env_fog_size)
		tab_next()
		
		// Fog height
		tab_control_dragger()
		draw_dragger("environment/fog/height", dx, dy, dragger_width, env_fog_height, env_fog_height / 100, 10, 2000, fog_height, 10, tab.environment.tbx_fog_height, action_env_fog_height)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Wind
	tab_control_switch()
	draw_button_collapse("environment/wind", collapse_map[?"environment/wind"], action_env_wind, env_wind, "environment/wind")
	tab_next()
	
	if (env_wind && collapse_map[?"environment/wind"])
	{
		tab_collapse_start()
		
		// Wind strength
		tab_control_dragger()
		draw_dragger("environment/wind/speed", dx, dy, dragger_width, round(env_wind_speed * 100), .1, 0, no_limit * 100, 10, 1, tab.environment.tbx_wind_speed, action_env_wind_speed)
		tab_next()
		
		// Wind amount
		tab_control_dragger()
		draw_dragger("environment/wind/strength", dx, dy, dragger_width, env_wind_strength, .1, 0, no_limit, 0.5, 0.05, tab.environment.tbx_wind_strength, action_env_wind_strength)
		tab_next()
		
		// Advanced mode only
		if (setting_advanced_mode)
		{
			// Wind angle
			tab_control_dragger()
			draw_dragger("environment/wind/direction", dx, dy, dragger_width, env_wind_direction, .1, -no_limit, no_limit, 45, 1, tab.environment.tbx_wind_direction, action_env_wind_direction)
			tab_next()
			
			// Wind direction speed
			tab_control_dragger()
			draw_dragger("environment/wind/directional_speed", dx, dy, dragger_width, round(env_wind_directional_speed * 100), .1, 0, no_limit, 20, 1, tab.environment.tbx_wind_directional_speed, action_env_wind_directional_speed)
			tab_next()
			
			// Wind direction strength
			tab_control_dragger()
			draw_dragger("environment/wind/directional_strength", dx, dy, dragger_width, env_wind_directional_strength, .01, 0, no_limit, 1.5, 0.05, tab.environment.tbx_wind_directional_strength, action_env_wind_directional_strength)
			tab_next()
		}
		
		tab_collapse_end()
	}
	
	// Animation speed (Advanced mode only)
	if (setting_advanced_mode)
	{
		tab_control_dragger()
		draw_dragger("environment/texture_animation_speed", dx, dy, dragger_width, round(env_texture_animation_speed * 100), .5, -no_limit, no_limit, 100, 1, tab.environment.tbx_texture_animation_speed, action_env_texture_animation_speed)
		tab_next()
	}
}
