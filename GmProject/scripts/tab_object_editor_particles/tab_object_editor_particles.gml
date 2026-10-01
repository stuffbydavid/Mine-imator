function tab_object_editor_particles()
{
	var sn, ud, setx, wid, textx, suffix, dividew, prefix;
	sn = (setting_z_is_up ? Y : Z) // South/north axis
	ud = (setting_z_is_up ? Z : Y) // Up/down axis
	suffix = ""
	dividew = content_width - floor(tab.scroll.needed * 12)
	
	// Settings
	setx = dx + dw - 24
	tab_control(24)
	
	if (draw_button_icon("particle_editor/export", setx, dy, 24, 24, false, icons.ASSET_EXPORT, null, false, "tooltip/particles/export"))
		particles_save(obj_edit)
	setx -= 28
	
	if (draw_button_icon("particle_editor/import", setx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltip/particles/import"))
		action_lib_pc_open()
	setx -= 4
	
	draw_divide_vertical(setx, dy, 24)
	setx -= 28
	
	tip_set_keybind(e_keybind.PARTICLES_CLEAR)
	if (draw_button_icon("particle_editor/clear", setx, dy, 24, 24, false, icons.DELETE, null, false, "tooltip/particles/clear"))
		action_lib_pc_clear()
	setx -= 28
	
	if (!obj_edit.pc_spawn_constant)
	{
		tip_set_keybind(e_keybind.PARTICLES_SPAWN)
		
		if (draw_button_icon("particle_editor/spawn", setx, dy, 24, 24, false, icons.PARTICLES, null, false, "tooltip/particles/spawn"))
			action_lib_pc_spawn()
		
		setx -= 28
	}
	
	draw_label_value(dx, dy, setx - dx, 24, text_get("particle_editor/count"), string(instance_number(obj_particle)))
	
	tab_next()
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	#region SPAWNING
	
	tab_control(16)
	draw_label(text_get("particle_editor/spawn/caption"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Spawn amount
	tab_control_togglebutton()
	togglebutton_add("particle_editor/spawn/constant", null, 1, obj_edit.pc_spawn_constant, action_lib_pc_spawn_constant)
	togglebutton_add("particle_editor/spawn/burst", null, 0, !obj_edit.pc_spawn_constant, action_lib_pc_spawn_constant)
	draw_togglebutton("particle_editor/spawn/type", dx, dy)
	tab_next()
	
	if (obj_edit.pc_spawn_constant)
		draw_tooltip_label("particle_editor/spawn/constant_tip", icons.PARTICLES, e_toast.INFO)
	else
		draw_tooltip_label("particle_editor/spawn/burst_tip", icons.PARTICLES, e_toast.INFO)
	
	draw_set_font(font_label)
	tab_control_dragger()
	draw_dragger("particle_editor/spawn/amount", dx, dy, 64, obj_edit.pc_spawn_amount, obj_edit.pc_spawn_constant ? 2 : 0.2, 1, no_limit, 100, 1, tab.tbx_spawn_amount, action_lib_pc_spawn_amount, string_width(text_get("particle_editor/spawn/amount")) + 8)
	
	draw_set_font(font_label)
	
	textx = dx + 64 + 16 + string_width(text_get("particle_editor/spawn/amount"))
	content_text = string_limit((obj_edit.pc_spawn_constant ? text_get("particle_editor/per_minute") : text_get("particle_editor/per_burst")), (dw - (textx - dx)) - 8)
	
	draw_label(content_text, textx, dy + (ui_small_height/2), fa_left, fa_middle, c_text_main, a_text_main, font_value)
	tab_next()
	
	// Spawn region
	tab_control_switch()
	draw_switch("particle_editor/spawn/region", dx, dy, obj_edit.pc_spawn_region_use, action_lib_pc_spawn_region_use)
	tab_next()
	
	if (obj_edit.pc_spawn_region_use)
	{
		prefix = "particle_editor/spawn/region/"
		
		var icon;
		switch (obj_edit.pc_spawn_region_type)
		{
			case "sphere":	icon = icons.BOUNDARY_CIRCLE; break
			case "cube":	icon = icons.BOUNDARY_CUBE; break
			case "box":		icon = icons.BOUNDARY_BOX; break
			case "path":	icon = icons.PATH; break
		}
		
		tab_control_menu()
		draw_button_menu(prefix + "type", e_menu.LIST, dx, dy, dw, 24, obj_edit.pc_spawn_region_type, text_get(prefix + "type_" + obj_edit.pc_spawn_region_type), action_lib_pc_spawn_region_type, false, null, icon)
		tab_next()
		
		switch (obj_edit.pc_spawn_region_type)
		{
			case "sphere":
			{
				tab_control_dragger()
				draw_dragger(prefix + "sphere_radius", dx, dy, 64, obj_edit.pc_spawn_region_sphere_radius, obj_edit.pc_spawn_region_sphere_radius / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_sphere_radius, action_lib_pc_spawn_region_sphere_radius)
				tab_next()
				
				break
			}
			
			case "cube":
			{
				tab_control_dragger()
				draw_dragger(prefix + "cube_size", dx, dy, 64, obj_edit.pc_spawn_region_cube_size, obj_edit.pc_spawn_region_cube_size / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_cube_size, action_lib_pc_spawn_region_cube_size)
				tab_next()
				
				break
			}
			
			case "box":
			{	
				axis_edit = X
				textfield_group_add(prefix + "box_xsize", obj_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_xsize, null, obj_edit.pc_spawn_region_box_size[axis_edit] / 100)
				axis_edit = sn
				textfield_group_add(prefix + "box_ysize", obj_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_ysize, null, obj_edit.pc_spawn_region_box_size[axis_edit] / 100)
				axis_edit = ud
				textfield_group_add(prefix + "box_zsize", obj_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_zsize, null, obj_edit.pc_spawn_region_box_size[axis_edit] / 100)
				
				tab_control_textfield_group(true)
				draw_textfield_group(prefix + "box_size", dx, dy, dw, null, 0, no_limit, 0, true, true, 1)
				tab_next()
				
				break
			}
			
			case "path":
			{
				if (obj_edit.pc_spawn_region_path)
					content_name = obj_edit.pc_spawn_region_path.display_name
				else
					content_name = text_get("list/none")
				
				tab_control_menu()
				draw_button_menu(prefix + "path", e_menu.LIST, dx, dy, dw, 24, obj_edit.pc_spawn_region_path, content_name, action_lib_pc_spawn_region_path)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(prefix + "path_radius", dx, dy, 64, obj_edit.pc_spawn_region_path_radius, obj_edit.pc_spawn_region_path_radius / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_path_radius, action_lib_pc_spawn_region_path_radius)
				tab_next()
				
				break
			}
		}
		
		draw_divide(dx, dy, dw)
		dy += 8
	}
	
	// Bounding box
	tab_control_menu()
	draw_button_menu("particle_editor/bounding_box", e_menu.LIST, dx, dy, dw, 24, obj_edit.pc_bounding_box_type, text_get("particle_editor/bounding_box/type_" + obj_edit.pc_bounding_box_type), action_lib_pc_bounding_box_type)
	tab_next()
	
	if (obj_edit.pc_bounding_box_type = "ground")
	{
		tab_control_dragger()
		draw_dragger("particle_editor/bounding_box/ground_" + (setting_z_is_up ? "z" : "y"), dx, dy, 64, obj_edit.pc_bounding_box_ground_z, 0.1, -no_limit, no_limit, 0, 0, tab.tbx_bounding_box_ground_z, action_lib_pc_bounding_box_ground_z)
		tab_next()
	}
	else if (obj_edit.pc_bounding_box_type = "custom")
	{
		prefix = "particle_editor/bounding_box/"
		
		// "From" position
		axis_edit = X
		textfield_group_add(prefix + "from_x", obj_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_xstart, null, 1, -no_limit, obj_edit.pc_bounding_box_custom_end[axis_edit])
		axis_edit = sn
		textfield_group_add(prefix + "from_y", obj_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_ystart, null, 1, -no_limit, obj_edit.pc_bounding_box_custom_end[axis_edit])
		axis_edit = ud
		textfield_group_add(prefix + "from_z", obj_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_zstart, null, 1, -no_limit, obj_edit.pc_bounding_box_custom_end[axis_edit])
		
		tab_control_textfield_group(true)
		draw_textfield_group(prefix + "custom_from", dx, dy, dw, 1, 0, no_limit, 0, true, true, 1)
		tab_next()
		
		// "To" position
		axis_edit = X
		textfield_group_add(prefix + "to_x", obj_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_xend, null, 1, obj_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		axis_edit = sn
		textfield_group_add(prefix + "to_y", obj_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_yend, null, 1, obj_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		axis_edit = ud
		textfield_group_add(prefix + "to_z", obj_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_zend, null, 1, obj_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		
		tab_control_textfield_group(true)
		draw_textfield_group(prefix + "custom_to", dx, dy, dw, 1, 0, no_limit, 0, true, true, 1)
		tab_next()
		
		tab_control_switch()
		draw_switch(prefix + "relative", dx, dy, obj_edit.pc_bounding_box_relative, action_lib_pc_bounding_box_relative)
		tab_next()
	}
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	#endregion
	#region DESTRUCTION
	
	tab_control(16)
	draw_label(text_get("particle_editor/destruction"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// "Destroy when..." label
	tab_control(16)
	draw_label(text_get("particle_editor/destroy"), dx, dy + 8, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	tab_next()
	
	// Destroy after animation
	tab_control_checkbox()
	draw_checkbox("particle_editor/destroy/animation_finish", dx, dy, obj_edit.pc_destroy_at_animation_finish, action_lib_pc_destroy_at_animation_finish)
	tab_next(false)
	
	// Destroy at bounding box
	tab_control_checkbox()
	draw_checkbox("particle_editor/destroy/bounding_box_toggle", dx, dy, obj_edit.pc_destroy_at_bounding_box, action_lib_pc_destroy_at_bounding_box)
	tab_next(false)
	
	// Destroy at amount
	tab_control_checkbox()
	draw_checkbox("particle_editor/destroy/amount", dx, dy, obj_edit.pc_destroy_at_amount, action_lib_pc_destroy_at_amount)
	
	wid = text_max_width("particle_editor/destroy/amount") + 8 + 26
	
	if (wid + dragger_width + 8 > dw)
	{
		tab_next(false)
		tab_control_dragger()
		wid = 0
	}
	
	draw_dragger("particle_editor/destroy/amount_val", dx + wid, dy, 64, obj_edit.pc_destroy_at_amount_val, 0.25, 0, no_limit, 200, 1, tab.tbx_destroy_at_amount_val, action_lib_pc_destroy_at_amount_val, wid, false)
	
	tab_next(wid = 0)
	
	// Destroy at a time
	tab_control_checkbox()
	draw_checkbox("particle_editor/destroy/time", dx, dy, obj_edit.pc_destroy_at_time, action_lib_pc_destroy_at_time)
	tab_next(!obj_edit.pc_destroy_at_time)
	
	if (obj_edit.pc_destroy_at_time)
	{
		tab_object_editor_particles_value("particle_editor/destroy/lifespan",
			obj_edit.pc_destroy_at_time_seconds, obj_edit.pc_destroy_at_time_israndom, obj_edit.pc_destroy_at_time_random_min, obj_edit.pc_destroy_at_time_random_max,
			0.05, 0, no_limit, [ 5, 5, 10 ], 0,
			[ tab.tbx_destroy_at_time_seconds, tab.tbx_destroy_at_time_random ],
			[ action_lib_pc_destroy_at_time_seconds, action_lib_pc_destroy_at_time_israndom, action_lib_pc_destroy_at_time_random_min, action_lib_pc_destroy_at_time_random_max ],
			null, false, suffix)
	}
	
	#endregion
	#region PARTICLE EMITTERS
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particle_editor/emitters"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	tab_control_sortlist(tab.type_list)
	sortlist_draw(tab.type_list, dx, dy, dw, tab_control_h, ptype_edit, false)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("particle_editor/type/add", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltip/particles/add"))
		action_lib_pc_type_add()
	
	if (draw_button_icon("particle_editor/type/duplicate", dx + 28, dy, 24, 24, false, icons.DUPLICATE, null, ptype_edit = null, "tooltip/particles/duplicate"))
		action_lib_pc_type_duplicate()
	
	if (draw_button_icon("particle_editor/type/delete", dx + (28 * 2), dy, 24, 24, false, icons.DELETE, null, ptype_edit = null, "tooltip/particles/delete"))
		action_lib_pc_type_remove()
		
	tab_next()
	
	if (ptype_edit = null)
		return 0
	
	content_capwid = text_caption_width("particle_editor/type/name",
							"particle_editor/type/spawn_rate",
							"particle_editor/type/temp",
							"particle_editor/type/sprite/tex",
							"particle_editor/type/sprite/tex_image",
							"particle_editor/type/sprite/template_pack",
							"particle_editor/type/sprite/template",
							"particle_editor/type/text")
	
	// Name
	tab.tbx_type_name.text = ptype_edit.name
	
	tab_control_dragger()
	draw_textfield("particle_editor/type/name", dx, dy, dw, 24, tab.tbx_type_name, action_lib_pc_type_name, "", "left")
	tab_next()
	
	// Spawn rate
	if (ds_list_size(obj_edit.pc_type_list) > 1)
	{
		tab_control_meter()
		draw_meter("particle_editor/type/spawn_rate", dx, dy, dw, ptype_edit.spawn_rate * 100, 0, 100, 100 / ds_list_size(obj_edit.pc_type_list), 1, tab.tbx_type_spawn_rate, action_lib_pc_type_spawn_rate)
		tab_next()
	}
	
	// Template
	tab_control_menu()
	
	content_text = text_get("particle_editor/type/sprite_sheet")
	if (ptype_edit.temp = particle_template)
		content_text = text_get("particle_editor/type/template")
	if (ptype_edit.temp)
		content_text = ptype_edit.temp.display_name
	
	draw_button_menu("particle_editor/type/temp", e_menu.LIST, dx, dy, dw, 24, ptype_edit.temp, content_text, action_lib_pc_type_temp)
	tab_next()
	
	// Sprite
	if (ptype_edit.temp < 0)
	{
		prefix = "particle_editor/type/sprite/"
		
		// Sprite sheet
		if (ptype_edit.temp = particle_sheet)
		{
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu(prefix + "tex", e_menu.LIST, dx, dy, dw, ui_large_height, ptype_edit.sprite_tex, res_eval(ptype_edit.sprite_tex).display_name, action_lib_pc_type_sprite_tex, false, res_eval(ptype_edit.sprite_tex).particles_texture[ptype_edit.sprite_tex_image])
			tab_next()
			
			// Image
			if (res_eval(ptype_edit.sprite_tex).type = e_res_type.PACK)
			{
				tab_control_togglebutton()
				togglebutton_add(prefix + "tex_image_1", null, 0, ptype_edit.sprite_tex_image = 0, action_lib_pc_type_sprite_tex_image)
				togglebutton_add(prefix + "tex_image_2", null, 1, ptype_edit.sprite_tex_image = 1, action_lib_pc_type_sprite_tex_image)
				draw_togglebutton(prefix + "tex_image", dx, dy)
				tab_next()
			}
			
			// Frames
			tab_object_editor_particles_framebox()
			
			// Frame width / height
			tab_control_textfield_group(true, false)
			textfield_group_add(prefix + "frame/width", ptype_edit.sprite_frame_width, 8, action_lib_pc_type_sprite_frame_width, axis_edit, tab.tbx_type_sprite_frame_width)
			textfield_group_add(prefix + "frame/height", ptype_edit.sprite_frame_height, 8, action_lib_pc_type_sprite_frame_height, axis_edit, tab.tbx_type_sprite_frame_height)
			draw_textfield_group(prefix + "frame/size", dx, dy, dw, 0.1, 1, no_limit, 1, true, false)
			tab_next()
			
			// Frames
			tab_control_textfield_group(true, false)
			textfield_group_add(prefix + "frame/start", ptype_edit.sprite_frame_start, 7, action_lib_pc_type_sprite_frame_start, axis_edit, tab.tbx_type_sprite_frame_start, null, 0.1, 0, no_limit, "particle_editor/from")
			textfield_group_add(prefix + "frame/end", ptype_edit.sprite_frame_end, 0, action_lib_pc_type_sprite_frame_end, axis_edit, tab.tbx_type_sprite_frame_end, null, 0.1, 0, no_limit, "particle_editor/to")
			draw_textfield_group(prefix + "frame/frames", dx, dy, dw, null, null, null, 1, true, false)
			tab_next()
		}
		else // Particle template
		{
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu(prefix + "template_pack", e_menu.LIST, dx, dy, dw, ui_large_height, ptype_edit.sprite_template_tex, res_eval(ptype_edit.sprite_template_tex).display_name, action_lib_pc_type_sprite_template_tex, false, res_eval(ptype_edit.sprite_template_tex).block_preview_texture)
			tab_next()
			
			// Template
			tab_control_menu()
			draw_button_menu(prefix + "template", e_menu.LIST, dx, dy, dw, 24, ptype_edit.sprite_template, text_get(prefix + "template/" + ptype_edit.sprite_template), action_lib_pc_type_sprite_template, false)
			tab_next()
			
			// Still frame
			tab_control_switch()
			draw_switch(prefix + "template_still_frame", dx, dy, ptype_edit.sprite_template_still_frame, action_lib_pc_type_sprite_template_still_frame)
			tab_next()
			
			// Random frame
			if (ptype_edit.sprite_template_still_frame)
			{
				tab_control_switch()
				draw_switch(prefix + "template_random_frame", dx, dy, ptype_edit.sprite_template_random_frame, action_lib_pc_type_sprite_template_random_frame)
				tab_next()
			}
			else
			{
				// Reverse template animation
				tab_control_switch()
				draw_switch(prefix + "template_reverse", dx, dy, ptype_edit.sprite_template_reverse, action_lib_pc_type_sprite_template_reverse)
				tab_next()
			}
		}
		
		if (!(ptype_edit.sprite_template_still_frame && ptype_edit.temp = particle_template))
		{
			// Animation speed
			tab_object_editor_particles_value(prefix + "animation/speed",
				ptype_edit.sprite_animation_speed, ptype_edit.sprite_animation_speed_israndom, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_max, 
				0.04, 0, no_limit, [ 5, 5, 10 ], 0,
				[ tab.tbx_type_sprite_animation_speed, tab.tbx_type_sprite_animation_speed_random ],
				[ action_lib_pc_type_sprite_animation_speed, action_lib_pc_type_sprite_animation_speed_israndom, action_lib_pc_type_sprite_animation_speed_random_min, action_lib_pc_type_sprite_animation_speed_random_max ],
				null, true, text_get("particle_editor/fps"))
			
			// On animation end
			tab_control_togglebutton()
			togglebutton_add(prefix + "animation/on_end_stop", null, 0, ptype_edit.sprite_animation_onend = 0, action_lib_pc_type_sprite_animation_onend)
			togglebutton_add(prefix + "animation/on_end_loop", null, 1, ptype_edit.sprite_animation_onend = 1, action_lib_pc_type_sprite_animation_onend)
			togglebutton_add(prefix + "animation/on_end_reverse", null, 2, ptype_edit.sprite_animation_onend = 2, action_lib_pc_type_sprite_animation_onend)
			draw_togglebutton(prefix + "animation/on_end", dx, dy)
			tab_next()
		}
		
		tab_object_editor_particles_preview()
	}
	else if (ptype_edit.temp.type = e_temp_type.TEXT) // Text field
	{
		tab_control(108)
		tab.tbx_type_text.text = ptype_edit.text
		draw_textfield("particle_editor/type/text", dx, dy, dw, 88, tab.tbx_type_text, action_lib_pc_type_text, "", "top")
		tab_next()
	}
	
	#endregion
	#region TRAJECTORY
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particle_editor/type/trajectory"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Launch angle
	tab_control_switch()
	
	if (draw_button_collapse("particle_editor/type/angle", !ptype_edit.angle_collapse, null, true, "particle_editor/type/angle"))
		ptype_edit.angle_collapse = !ptype_edit.angle_collapse
	
	tab_next()
	
	if (!ptype_edit.angle_collapse)
	{
		prefix = "particle_editor/type/angle/"
				
		tab_collapse_start()
		
		content_capwid = (ptype_edit.angle_extend ? text_caption_width(prefix + "x", prefix + "y", prefix + "z",
																	   prefix + "speed", prefix + "speed_add", prefix + "speed_mul") :
												    text_caption_width(prefix + "xyz", prefix + "speed", prefix + "speed_add",
																  	   prefix + "speed_mul"))
		
		// Extend XYZ settings
		tab_control_switch()
		draw_switch(prefix + "extend", dx, dy, ptype_edit.angle_extend, action_lib_pc_type_angle_extend)
		tab_next()
		
		axis_edit = X
		tab_object_editor_particles_value(prefix + (ptype_edit.angle_extend ? "x" : "xyz"),
			ptype_edit.angle[X], ptype_edit.angle_israndom[X], ptype_edit.angle_random_min[X], ptype_edit.angle_random_max[X], 
			0.25, -no_limit, no_limit, [ 0, 0, 360 ], 0,
			[ tab.tbx_type_xangle, tab.tbx_type_xangle_random ],
			[ action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max ],
			content_capwid)
		
		if (ptype_edit.angle_extend)
		{
			axis_edit = sn
			tab_object_editor_particles_value(prefix + "y",
				ptype_edit.angle[sn], ptype_edit.angle_israndom[sn], ptype_edit.angle_random_min[sn], ptype_edit.angle_random_max[sn], 
				0.25, -no_limit, no_limit, [ 0, 0, 360 ], 0,
				[ tab.tbx_type_yangle, tab.tbx_type_yangle_random ],
				[ action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max ],
				content_capwid)
			
			axis_edit = ud
			tab_object_editor_particles_value(prefix + "z",
				ptype_edit.angle[ud], ptype_edit.angle_israndom[ud], ptype_edit.angle_random_min[ud], ptype_edit.angle_random_max[ud], 
				0.25, -no_limit, no_limit, [ 0, 0, 360 ], 0,
				[ tab.tbx_type_zangle, tab.tbx_type_zangle_random ],
				[ action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max ],
				content_capwid)
		}
		
		tab_object_editor_particles_value(prefix + "speed",
			ptype_edit.angle_speed, ptype_edit.angle_speed_israndom, ptype_edit.angle_speed_random_min, ptype_edit.angle_speed_random_max, 
			0.25, -no_limit, no_limit, [ 20, 0, 20 ], 0,
			[ tab.tbx_type_angle_speed, tab.tbx_type_angle_speed_random ],
			[ action_lib_pc_type_angle_speed, action_lib_pc_type_angle_speed_israndom, action_lib_pc_type_angle_speed_random_min, action_lib_pc_type_angle_speed_random_max ],
			content_capwid, true, suffix)
		
		tab_object_editor_particles_value(prefix + "speed_add",
			ptype_edit.angle_speed_add, ptype_edit.angle_speed_add_israndom, ptype_edit.angle_speed_add_random_min, ptype_edit.angle_speed_add_random_max, 
			0.25, -no_limit, no_limit, [ 0, -1, 1 ], 0,
			[ tab.tbx_type_angle_speed_add, tab.tbx_type_angle_speed_add_random ],
			[ action_lib_pc_type_angle_speed_add, action_lib_pc_type_angle_speed_add_israndom, action_lib_pc_type_angle_speed_add_random_min, action_lib_pc_type_angle_speed_add_random_max ],
			content_capwid, true, suffix)
		
		tab_object_editor_particles_value(prefix + "speed_mul",
			ptype_edit.angle_speed_mul, ptype_edit.angle_speed_mul_israndom, ptype_edit.angle_speed_mul_random_min, ptype_edit.angle_speed_mul_random_max, 
			0.25, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
			[ tab.tbx_type_angle_speed_mul, tab.tbx_type_angle_speed_mul_random ],
			[ action_lib_pc_type_angle_speed_mul, action_lib_pc_type_angle_speed_mul_israndom, action_lib_pc_type_angle_speed_mul_random_min, action_lib_pc_type_angle_speed_mul_random_max ],
			content_capwid, true, suffix)
		
		tab_collapse_end()
	}
	
	// Speed
	tab_control_switch()
	
	if (draw_button_collapse("particle_editor/type/speed", !ptype_edit.spd_collapse, null, true, "particle_editor/type/speed"))
		ptype_edit.spd_collapse = !ptype_edit.spd_collapse
	
	tab_next()
	
	if (!ptype_edit.spd_collapse)
	{
		prefix = "particle_editor/type/speed/"
		
		tab_collapse_start()
		
		content_capwid = (ptype_edit.spd_extend ? text_caption_width(prefix + "x", prefix + "y", prefix + "z",
													  				 prefix + "x_add", prefix + "y_add", prefix + "z_add",
													 				 prefix + "x_mul", prefix + "y_mul", prefix + "z_mul") :
												  text_caption_width(prefix + "xyz", prefix + "xyz_add", prefix + "xyz_mul"))
		
		// Extend XYZ settings
		tab_control_switch()
		draw_switch(prefix + "extend", dx, dy, ptype_edit.spd_extend, action_lib_pc_type_spd_extend)
		tab_next()
		
		axis_edit = X
		tab_object_editor_particles_value(prefix + (ptype_edit.spd_extend ? "x" : "xyz"),
			ptype_edit.spd[X], ptype_edit.spd_israndom[X], ptype_edit.spd_random_min[X], ptype_edit.spd_random_max[X], 
			0.25, -no_limit, no_limit, [ 0, -20, 20 ], 0,
			[ tab.tbx_type_xspd, tab.tbx_type_xspd_random ],
			[ action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max ],
			content_capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_object_editor_particles_value(prefix + "y",
				ptype_edit.spd[sn], ptype_edit.spd_israndom[sn], ptype_edit.spd_random_min[sn], ptype_edit.spd_random_max[sn], 
				0.25, -no_limit, no_limit, [ 0, -20, 20 ], 0,
				[ tab.tbx_type_yspd, tab.tbx_type_yspd_random ],
				[ action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max ],
				content_capwid, true, suffix)
			
			axis_edit = ud
			tab_object_editor_particles_value(prefix + "z",
				ptype_edit.spd[ud], ptype_edit.spd_israndom[ud], ptype_edit.spd_random_min[ud], ptype_edit.spd_random_max[ud], 
				0.25, -no_limit, no_limit, [ 0, -20, 20 ], 0,
				[ tab.tbx_type_zspd, tab.tbx_type_zspd_random ],
				[ action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max ],
				content_capwid, true, suffix)
		}
		
		// Speed add
		axis_edit = X
		
		tab_object_editor_particles_value(prefix + (ptype_edit.spd_extend ? "x" : "xyz") + "_add",
			ptype_edit.spd_add[X], ptype_edit.spd_add_israndom[X], ptype_edit.spd_add_random_min[X], ptype_edit.spd_add_random_max[X], 
			0.1, -no_limit, no_limit, [ 0, -1, 1 ], 0,
			[ tab.tbx_type_xspd_add, tab.tbx_type_xspd_add_random ],
			[ action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max ],
			content_capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_object_editor_particles_value(prefix + "y_add",
				ptype_edit.spd_add[sn], ptype_edit.spd_add_israndom[sn], ptype_edit.spd_add_random_min[sn], ptype_edit.spd_add_random_max[sn], 
				0.1, -no_limit, no_limit, [ 0, -1, 1 ], 0,
				[ tab.tbx_type_yspd_add, tab.tbx_type_yspd_add_random ],
				[ action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max ],
				content_capwid, true, suffix)
			
			axis_edit = ud
			tab_object_editor_particles_value(prefix + "z_add",
				ptype_edit.spd_add[ud], ptype_edit.spd_add_israndom[ud], ptype_edit.spd_add_random_min[ud], ptype_edit.spd_add_random_max[ud], 
				0.1, -no_limit, no_limit, [ 0, -1, 1 ], 0,
				[ tab.tbx_type_zspd_add, tab.tbx_type_zspd_add_random ],
				[ action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max ],
				content_capwid, true, suffix)
		}
		
		// Speed multiply
		axis_edit = X
		tab_object_editor_particles_value(prefix + (ptype_edit.spd_extend ? "x" : "xyz") + "_mul",
			ptype_edit.spd_mul[X], ptype_edit.spd_mul_israndom[X], ptype_edit.spd_mul_random_min[X], ptype_edit.spd_mul_random_max[X], 
			0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
			[ tab.tbx_type_xspd_mul, tab.tbx_type_xspd_mul_random ],
			[ action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max ],
			content_capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_object_editor_particles_value(prefix + "y_mul",
				ptype_edit.spd_mul[sn], ptype_edit.spd_mul_israndom[sn], ptype_edit.spd_mul_random_min[sn], ptype_edit.spd_mul_random_max[sn], 
				0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
				[ tab.tbx_type_yspd_mul, tab.tbx_type_yspd_mul_random ],
				[ action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max ],
				content_capwid, true, suffix)
			
			axis_edit = ud
			tab_object_editor_particles_value(prefix + "z_mul",
				ptype_edit.spd_mul[ud], ptype_edit.spd_mul_israndom[ud], ptype_edit.spd_mul_random_min[ud], ptype_edit.spd_mul_random_max[ud], 
				0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
				[ tab.tbx_type_zspd_mul, tab.tbx_type_zspd_mul_random ],
				[ action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max ],
				content_capwid, true, suffix)
		}
		
		tab_collapse_end(false)
	}
	
	#endregion
	#region ROTATION
	
	if (ptype_edit.temp || (ptype_edit.temp = particle_sheet || ptype_edit.temp = particle_template))
	{
		draw_divide(content_x, dy, dividew)
		dy += 12
		
		tab_control(16)
		draw_label(text_get("particle_editor/type/rotation"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
		tab_next()
		
		if (ptype_edit.temp)
		{
			// Launch angle
			tab_control_switch()
			
			if (draw_button_collapse("particle_editor/type/rotation/initial", !ptype_edit.rot_collapse, null, true, "particle_editor/type/rotation/initial"))
				ptype_edit.rot_collapse = !ptype_edit.rot_collapse
			
			tab_next()
			
			if (!ptype_edit.rot_collapse)
			{
				prefix = "particle_editor/type/rotation/"
				
				tab_collapse_start()
				
				// Rotation
				content_capwid = (ptype_edit.rot_extend ? text_caption_width(prefix + "x", prefix + "y", prefix + "z") :
														  text_caption_width(prefix + "xyz"))
				
				// Use spawner angle
				tab_control_switch()
				draw_switch(prefix + "spawner_angle", dx, dy, ptype_edit.rot_spawner_angle, action_lib_pc_type_rot_spawner_angle)
				tab_next()
				
				// Extend XYZ settings
				tab_control_switch()
				draw_switch(prefix + "extend", dx, dy, ptype_edit.rot_extend, action_lib_pc_type_rot_extend)
				tab_next()
				
				axis_edit = X
				tab_object_editor_particles_value(prefix + (ptype_edit.rot_extend ? "x" : "xyz"),
					ptype_edit.rot[X], ptype_edit.rot_israndom[X], ptype_edit.rot_random_min[X], ptype_edit.rot_random_max[X], 
					0.2, -no_limit, no_limit, [ 0, 0, 360 ], 0,
					[ tab.tbx_type_xrot, tab.tbx_type_xrot_random ],
					[ action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max ],
					content_capwid)
				
				if (ptype_edit.rot_extend)
				{
					axis_edit = sn
					tab_object_editor_particles_value(prefix + "y",
						ptype_edit.rot[sn], ptype_edit.rot_israndom[sn], ptype_edit.rot_random_min[sn], ptype_edit.rot_random_max[sn], 
						0.2, -no_limit, no_limit, [ 0, 0, 360 ], 0,
						[ tab.tbx_type_yrot, tab.tbx_type_yrot_random ],
						[ action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max ],
						content_capwid)
					
					axis_edit = ud
					tab_object_editor_particles_value(prefix + "z",
						ptype_edit.rot[ud], ptype_edit.rot_israndom[ud], ptype_edit.rot_random_min[ud], ptype_edit.rot_random_max[ud], 
						0.2, -no_limit, no_limit, [ 0, 0, 360 ], 0,
						[ tab.tbx_type_zrot, tab.tbx_type_zrot_random ],
						[ action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max ],
						content_capwid)
				}
				
				tab_collapse_end()
			}
			
			// Rotation speed
			tab_control_switch()
			
			if (draw_button_collapse("particle_editor/type/rotation/speed", !ptype_edit.rot_spd_collapse, null, true, "particle_editor/type/rotation/speed"))
				ptype_edit.rot_spd_collapse = !ptype_edit.rot_spd_collapse
			
			tab_next()
			
			if (!ptype_edit.rot_spd_collapse)
			{
				prefix = "particle_editor/type/rotation/speed/"
				
				tab_collapse_start()
				
				content_capwid = (ptype_edit.rot_spd_extend ? text_caption_width(prefix + "x", prefix + "y", prefix + "z",
																				 prefix + "x_add", prefix + "y_add", prefix + "z_add",
																				 prefix + "x_mul", prefix + "y_mul", prefix + "z_mul") :
															  text_caption_width(prefix + "xyz", prefix + "xyz_add", prefix + "xyz_mul"))
				
				// Extend XYZ settings
				tab_control_switch()
				draw_switch(prefix + "extend", dx, dy, ptype_edit.rot_spd_extend, action_lib_pc_type_rot_spd_extend)
				tab_next()
				
				axis_edit = X
				tab_object_editor_particles_value(prefix + (ptype_edit.rot_spd_extend ? "x" : "xyz"),
					ptype_edit.rot_spd[X], ptype_edit.rot_spd_israndom[X], ptype_edit.rot_spd_random_min[X], ptype_edit.rot_spd_random_max[X], 
					0.5, -no_limit, no_limit, [ 0, -180, 180 ], 0,
					[ tab.tbx_type_xrot_spd, tab.tbx_type_xrot_spd_random ],
					[ action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max ],
					content_capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_object_editor_particles_value(prefix + "y",
						ptype_edit.rot_spd[sn], ptype_edit.rot_spd_israndom[sn], ptype_edit.rot_spd_random_min[sn], ptype_edit.rot_spd_random_max[sn], 
						0.5, -no_limit, no_limit, [ 0, -180, 180 ], 0,
						[ tab.tbx_type_yrot_spd, tab.tbx_type_yrot_spd_random ],
						[ action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max ],
						content_capwid, true, suffix)
					
					axis_edit = ud
					tab_object_editor_particles_value(prefix + "z",
						ptype_edit.rot_spd[ud], ptype_edit.rot_spd_israndom[ud], ptype_edit.rot_spd_random_min[ud], ptype_edit.rot_spd_random_max[ud], 
						0.5, -no_limit, no_limit, [ 0, -180, 180 ], 0,
						[ tab.tbx_type_zrot_spd, tab.tbx_type_zrot_spd_random ],
						[ action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max ],
						content_capwid, true, suffix)
				}
				
				// Rotation speed add
				axis_edit = X
				tab_object_editor_particles_value(prefix + (ptype_edit.rot_spd_extend ? "x" : "xyz") + "_add",
					ptype_edit.rot_spd_add[X], ptype_edit.rot_spd_add_israndom[X], ptype_edit.rot_spd_add_random_min[X], ptype_edit.rot_spd_add_random_max[X], 
					0.1, -no_limit, no_limit, [ 0, -10, 10 ], 0,
					[ tab.tbx_type_xrot_spd_add, tab.tbx_type_xrot_spd_add_random ],
					[ action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max ],
					content_capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_object_editor_particles_value(prefix + "y_add",
						ptype_edit.rot_spd_add[sn], ptype_edit.rot_spd_add_israndom[sn], ptype_edit.rot_spd_add_random_min[sn], ptype_edit.rot_spd_add_random_max[sn], 
						0.05, -no_limit, no_limit, [ 0, -10, 10 ], 0,
						[ tab.tbx_type_yrot_spd_add, tab.tbx_type_yrot_spd_add_random ],
						[ action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max ],
						content_capwid, true, suffix)
					
					axis_edit = ud
					tab_object_editor_particles_value(prefix + "z_add",
						ptype_edit.rot_spd_add[ud], ptype_edit.rot_spd_add_israndom[ud], ptype_edit.rot_spd_add_random_min[ud], ptype_edit.rot_spd_add_random_max[ud], 
						0.1, -no_limit, no_limit, [ 0, -10, 10 ], 0,
						[ tab.tbx_type_zrot_spd_add, tab.tbx_type_zrot_spd_add_random ],
						[ action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max ],
						content_capwid, true, suffix)
				}
				
				// Rotation speed multiplier
				axis_edit = X
				tab_object_editor_particles_value(prefix + (ptype_edit.rot_spd_extend ? "x" : "xyz") + "_mul",
					ptype_edit.rot_spd_mul[X], ptype_edit.rot_spd_mul_israndom[X], ptype_edit.rot_spd_mul_random_min[X], ptype_edit.rot_spd_mul_random_max[X], 
					0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
					[ tab.tbx_type_xrot_spd_mul, tab.tbx_type_xrot_spd_mul_random ],
					[ action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max ],
					content_capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_object_editor_particles_value(prefix + "y_mul",
						ptype_edit.rot_spd_mul[sn], ptype_edit.rot_spd_mul_israndom[sn], ptype_edit.rot_spd_mul_random_min[sn], ptype_edit.rot_spd_mul_random_max[sn], 
						0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
						[ tab.tbx_type_yrot_spd_mul, tab.tbx_type_yrot_spd_mul_random ],
						[ action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max ],
						content_capwid, true, suffix)
					
					axis_edit = ud
					tab_object_editor_particles_value(prefix + "z_mul",
						ptype_edit.rot_spd_mul[ud], ptype_edit.rot_spd_mul_israndom[ud], ptype_edit.rot_spd_mul_random_min[ud], ptype_edit.rot_spd_mul_random_max[ud], 
						0.005, 0, no_limit, [ 1, 0.75, 0.9 ], 0,
						[ tab.tbx_type_zrot_spd_mul, tab.tbx_type_zrot_spd_mul_random ],
						[ action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max ],
						content_capwid, true, suffix)
				}
				
				tab_collapse_end()
			}
		}
		
		// Sprite angle
		if (ptype_edit.temp = particle_sheet || ptype_edit.temp = particle_template)
		{
			content_capwid = text_caption_width("particle_editor/type/sprite_angle", "particle_editor/type/sprite_angle_add")
			
			tab_object_editor_particles_value("particle_editor/type/sprite_angle",
				ptype_edit.sprite_angle, ptype_edit.sprite_angle_israndom, ptype_edit.sprite_angle_random_min, ptype_edit.sprite_angle_random_max, 
				0.2, 0, no_limit, [ 0, 0, 360 ], 0,
				[ tab.tbx_type_sprite_angle, tab.tbx_type_sprite_angle_random ],
				[ action_lib_pc_type_sprite_angle, action_lib_pc_type_sprite_angle_israndom, action_lib_pc_type_sprite_angle_random_min, action_lib_pc_type_sprite_angle_random_max ],
				content_capwid)
			
			// Angle change
			tab_object_editor_particles_value("particle_editor/type/sprite_angle_add",
				ptype_edit.sprite_angle_add, ptype_edit.sprite_angle_add_israndom, ptype_edit.sprite_angle_add_random_min, ptype_edit.sprite_angle_add_random_max, 
				0.1, -no_limit, no_limit, [ 0, -90, 90 ], 0,
				[ tab.tbx_type_sprite_angle_add, tab.tbx_type_sprite_angle_add_random ],
				[ action_lib_pc_type_sprite_angle_add, action_lib_pc_type_sprite_angle_add_israndom, action_lib_pc_type_sprite_angle_add_random_min, action_lib_pc_type_sprite_angle_add_random_max ],
				content_capwid, true, suffix)
		}
	}
	
	#endregion
	#region SCALE
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particle_editor/type/scale"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Scale
	content_capwid = text_caption_width("particle_editor/type/initial_scale", "particle_editor/type/scale_add")
	
	tab_object_editor_particles_value("particle_editor/type/initial_scale",
		ptype_edit.scale, ptype_edit.scale_israndom, ptype_edit.scale_random_min, ptype_edit.scale_random_max, 
		0.01, 0, no_limit, [ 1, 0.5, 2 ], 0,
		[ tab.tbx_type_scale, tab.tbx_type_scale_random ],
		[ action_lib_pc_type_scale, action_lib_pc_type_scale_israndom, action_lib_pc_type_scale_random_min, action_lib_pc_type_scale_random_max ],
		content_capwid)
	
	// Scale change
	tab_object_editor_particles_value("particle_editor/type/scale_add",
		ptype_edit.scale_add, ptype_edit.scale_add_israndom, ptype_edit.scale_add_random_min, ptype_edit.scale_add_random_max, 
		0.01, -no_limit, no_limit, [ 0, -0.2, -0.1 ], 0,
		[ tab.tbx_type_scale_add, tab.tbx_type_scale_add_random ],
		[ action_lib_pc_type_scale_add, action_lib_pc_type_scale_add_israndom, action_lib_pc_type_scale_add_random_min, action_lib_pc_type_scale_add_random_max ],
		content_capwid, true, suffix)
	dy += 10
	
	#endregion
	#region APPEARANCE
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particle_editor/type/appearance"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Alpha
	tab_control_meter()
	
	// Randomize alpha
	draw_button_icon("particle_editor/randomalpha", dx + dw - ui_small_height, dy, ui_small_height, ui_small_height, ptype_edit.alpha_israndom, icons.RANDOMIZE, action_lib_pc_type_alpha_israndom, false, "tooltip/particles/random")
	
	if (ptype_edit.alpha_israndom)
		draw_meter_range("particle_editor/type/opacity", dx, dy, dw - 36, 0, 100, 1, round(ptype_edit.alpha_random_min * 100), round(ptype_edit.alpha_random_max * 100), 0, 100, tab.tbx_type_alpha, tab.tbx_type_alpha_random, action_lib_pc_type_alpha_random_min, action_lib_pc_type_alpha_random_max)
	else
		draw_meter("particle_editor/type/opacity", dx, dy, dw - 36, round(ptype_edit.alpha * 100), 0, 100, 100, 1, tab.tbx_type_alpha, action_lib_pc_type_alpha)
	tab_next()
	
	// Alpha change
	tab_object_editor_particles_value("particle_editor/type/opacity_add",
		ptype_edit.alpha_add * 100, ptype_edit.alpha_add_israndom, ptype_edit.alpha_add_random_min * 100, ptype_edit.alpha_add_random_max * 100, 
		0.5, -no_limit, no_limit, [ 0, -10, -5 ], 0,
		[ tab.tbx_type_alpha_add, tab.tbx_type_alpha_add_random ],
		[ action_lib_pc_type_alpha_add, action_lib_pc_type_alpha_add_israndom, action_lib_pc_type_alpha_add_random_min, action_lib_pc_type_alpha_add_random_max ],
		null, true, suffix)
	
	// Color
	var colwid;
	wid = (dw - 36)
	colwid = floor((wid - 8)/2)
	
	// Color mix
	tab_control_switch()
	draw_switch("particle_editor/type/color/mix_enabled", dx, dy, ptype_edit.color_mix_enabled, action_lib_pc_type_color_mix_enabled)
	tab_next()
	
	if (ptype_edit.color_mix_enabled)
	{
		tab_control(20)
		draw_label(text_get("particle_editor/type/color/start"), dx, dy + 10, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		tab_next()
	}
	
	tab_control_color()
	draw_button_icon("particle_editor/randomcolor", dx + dw - ui_small_height, dy + (tab_control_h/2) - 12, ui_small_height, ui_small_height, ptype_edit.color_israndom, icons.RANDOMIZE, action_lib_pc_type_color_israndom, false, "tooltip/particles/random")
	if (ptype_edit.color_israndom)
	{
		content_name = ptype_edit.color_mix_enabled ? "particle_editor/type/color/start_color_1" : "particle_editor/type/color/color_1"
		draw_button_color(content_name, dx, dy, colwid, ptype_edit.color_random_start, c_gray, false, action_lib_pc_type_color_random_start)
		
		content_name = ptype_edit.color_mix_enabled ? "particle_editor/type/color/start_color_2" : "particle_editor/type/color/color_2"
		draw_button_color(content_name, dx + colwid + 8, dy, colwid, ptype_edit.color_random_end, c_white, false, action_lib_pc_type_color_random_end)
	}
	else
	{
		content_name = ptype_edit.color_mix_enabled ? "particle_editor/type/color/start_color" : "particle_editor/type/color/color"
		draw_button_color(content_name, dx, dy, wid, ptype_edit.color, c_white, false, action_lib_pc_type_color)
	}
	tab_next()
	
	if (ptype_edit.color_mix_enabled)
	{
		tab_control(20)
		draw_label(text_get("particle_editor/type/color/end"), dx, dy + 10, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		tab_next()
		
		tab_control_color()
		draw_button_icon("particle_editor/randommixcolor", dx + dw - ui_small_height, dy + (tab_control_h/2) - 12, ui_small_height, ui_small_height, ptype_edit.color_mix_israndom, icons.RANDOMIZE, action_lib_pc_type_color_mix_israndom, false, "tooltip/particles/random")
		if (ptype_edit.color_mix_israndom)
		{
			draw_button_color("particle_editor/type/color/end_color_1", dx, dy, colwid, ptype_edit.color_mix_random_start, c_gray, false, action_lib_pc_type_color_mix_random_start)
			draw_button_color("particle_editor/type/color/end_color_2", dx + colwid + 8, dy, colwid, ptype_edit.color_mix_random_end, c_white, false, action_lib_pc_type_color_mix_random_end)
		}
		else
			draw_button_color("particle_editor/type/color/end_color", dx, dy, wid, ptype_edit.color_mix, c_black, false, action_lib_pc_type_color_mix)
		tab_next()
		
		tab_object_editor_particles_value("particle_editor/type/color/mix_time",
			ptype_edit.color_mix_time, ptype_edit.color_mix_time_israndom, ptype_edit.color_mix_time_random_min, ptype_edit.color_mix_time_random_max, 
			0.05, 0, no_limit, [ 3, 1, 5 ], 0,
			[ tab.tbx_type_color_mix_time, tab.tbx_type_color_mix_time_random ],
			[ action_lib_pc_type_color_mix_time, action_lib_pc_type_color_mix_time_israndom, action_lib_pc_type_color_mix_time_random_min, action_lib_pc_type_color_mix_time_random_max ],
			null, true, suffix)
	}
	
	#endregion
	#region SIMULATION
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particle_editor/type/simulation"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Spawn region
	tab_control_switch()
	draw_switch("particle_editor/type/spawn_region", dx, dy, ptype_edit.spawn_region, action_lib_pc_type_spawn_region)
	tab_next()
	
	// Orbit attractor
	tab_control_switch()
	draw_switch("particle_editor/type/orbit", dx, dy, ptype_edit.orbit, action_lib_pc_type_orbit)
	tab_next()
	
	tab_control_switch()
	draw_switch("particle_editor/type/bounding_box", dx, dy, ptype_edit.bounding_box, action_lib_pc_type_bounding_box)
	tab_next()
	
	// Bounding box
	if (ptype_edit.bounding_box)
	{
		// Bounce
		tab_control_switch()
		draw_switch("particle_editor/type/bounce", dx, dy + 1, ptype_edit.bounce, action_lib_pc_type_bounce)
		tab_next()
		
		if (ptype_edit.bounce)
		{
			tab_control_dragger()
			draw_dragger("particle_editor/type/bounce_factor", dx, dy, 64, ptype_edit.bounce_factor, 0.01, 0, no_limit, 0.5, 0, tab.tbx_type_bounce_factor, action_lib_pc_type_bounce_factor)
			tab_next()
		}
	}
	
	#endregion
}
