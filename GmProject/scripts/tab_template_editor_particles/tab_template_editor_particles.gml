/// tab_template_editor_particles()

function tab_template_editor_particles()
{
	var capwid, setx, wid, text, textx, suffix, dividew;
	var sn, ud;
	sn = (setting_z_is_up ? Y : Z) // South/north axis
	ud = (setting_z_is_up ? Z : Y) // Up/down axis
	suffix = ""
	dividew = content_width - floor(tab.scroll.needed * 12)
	
	// Settings
	setx = dx + dw - 24
	tab_control(24)
	
	if (draw_button_icon("particleeditorexport", setx, dy, 24, 24, false, icons.ASSET_EXPORT, null, false, "tooltipparticlesexport"))
		particles_save()
	setx -= 28
	
	if (draw_button_icon("particleeditorimport", setx, dy, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltipparticlesimport"))
		action_lib_pc_open()
	setx -= 4
	
	draw_divide_vertical(setx, dy, 24)
	setx -= 28
	
	tip_set_keybind(e_keybind.PARTICLES_CLEAR)
	if (draw_button_icon("particleeditorclear", setx, dy, 24, 24, false, icons.DELETE, null, false, "tooltipparticlesclear"))
		action_lib_pc_clear()
	setx -= 28
	
	if (!temp_edit.pc_spawn_constant)
	{
		tip_set_keybind(e_keybind.PARTICLES_SPAWN)
		
		if (draw_button_icon("particleeditorspawn", setx, dy, 24, 24, false, icons.PARTICLES, null, false, "tooltipparticlesspawn"))
			action_lib_pc_spawn()
		
		setx -= 28
	}
	
	draw_label_value(dx, dy, setx - dx, 24, text_get("particleeditorcount"), string(instance_number(obj_particle)))
	
	tab_next()
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	#region SPAWNING
	
	tab_control(16)
	draw_label(text_get("particleeditorspawncaption"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Spawn amount
	tab_control_togglebutton()
	togglebutton_add("particleeditorspawnconstant", null, 1, temp_edit.pc_spawn_constant, action_lib_pc_spawn_constant)
	togglebutton_add("particleeditorspawnburst", null, 0, !temp_edit.pc_spawn_constant, action_lib_pc_spawn_constant)
	draw_togglebutton("particleeditorspawntype", dx, dy)
	tab_next()
	
	if (temp_edit.pc_spawn_constant)
		draw_tooltip_label("particleeditorspawnconstanttip", icons.PARTICLES, e_toast.INFO)
	else
		draw_tooltip_label("particleeditorspawnbursttip", icons.PARTICLES, e_toast.INFO)
	
	draw_set_font(font_label)
	tab_control_dragger()
	draw_dragger("particleeditorspawnamount", dx, dy, 64, temp_edit.pc_spawn_amount, temp_edit.pc_spawn_constant ? 2 : (1 / 5), 1, no_limit, 100, 1, tab.tbx_spawn_amount, action_lib_pc_spawn_amount, string_width(text_get("particleeditorspawnamount")) + 8)
	
	draw_set_font(font_label)
	
	textx = dx + 64 + 16 + string_width(text_get("particleeditorspawnamount"))
	text = string_limit((temp_edit.pc_spawn_constant ? text_get("particleeditorperminute") : text_get("particleeditorperburst")), (dw - (textx - dx)) - 8)
	
	draw_label(text, textx, dy + (ui_small_height/2), fa_left, fa_middle, c_text_main, a_text_main, font_value)
	tab_next()
	
	// Spawn region
	tab_control_switch()
	draw_switch("particleeditorspawnregion", dx, dy, temp_edit.pc_spawn_region_use, action_lib_pc_spawn_region_use)
	tab_next()
	
	if (temp_edit.pc_spawn_region_use)
	{
		var icon, name;
		switch (temp_edit.pc_spawn_region_type)
		{
			case "sphere":	icon = icons.BOUNDARY_CIRCLE	break
			case "cube":	icon = icons.BOUNDARY_CUBE		break
			case "box":		icon = icons.BOUNDARY_BOX		break
			case "path":	icon = icons.PATH				break
		}
		
		tab_control_menu()
		draw_button_menu("particleeditorspawnregiontype", e_menu.LIST, dx, dy, dw, 24, temp_edit.pc_spawn_region_type, text_get("particleeditorspawnregiontype" + temp_edit.pc_spawn_region_type), action_lib_pc_spawn_region_type, false, null, icon)
		tab_next()
		
		switch (temp_edit.pc_spawn_region_type)
		{
			case "sphere":
			{
				tab_control_dragger()
				draw_dragger("particleeditorspawnregionsphereradius", dx, dy, 64, temp_edit.pc_spawn_region_sphere_radius, temp_edit.pc_spawn_region_sphere_radius / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_sphere_radius, action_lib_pc_spawn_region_sphere_radius)
				tab_next()
				
				break
			}
			
			case "cube":
			{
				tab_control_dragger()
				draw_dragger("particleeditorspawnregioncubesize", dx, dy, 64, temp_edit.pc_spawn_region_cube_size, temp_edit.pc_spawn_region_cube_size / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_cube_size, action_lib_pc_spawn_region_cube_size)
				tab_next()
				
				break
			}
			
			case "box":
			{	
				axis_edit = X
				textfield_group_add("particleeditorspawnregionboxxsize", temp_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_xsize, null, temp_edit.pc_spawn_region_box_size[axis_edit] / 100)
				axis_edit = sn
				textfield_group_add("particleeditorspawnregionboxysize", temp_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_ysize, null, temp_edit.pc_spawn_region_box_size[axis_edit] / 100)
				axis_edit = ud
				textfield_group_add("particleeditorspawnregionboxzsize", temp_edit.pc_spawn_region_box_size[axis_edit], 200, action_lib_pc_spawn_region_box_size, axis_edit, tab.tbx_spawn_region_box_zsize, null, temp_edit.pc_spawn_region_box_size[axis_edit] / 100)
				
				tab_control_textfield_group()
				draw_textfield_group("particleeditorspawnregionboxsize", dx, dy, dw, null, 0, no_limit, 0, true, true, 1)
				tab_next()
				
				break
			}
			
			case "path":
			{
				var name;
				
				if (temp_edit.pc_spawn_region_path)
					name = temp_edit.pc_spawn_region_path.display_name
				else
					name = text_get("listnone")
				
				tab_control_menu()
				draw_button_menu("particleeditorspawnregionpath", e_menu.LIST, dx, dy, dw, 24, temp_edit.pc_spawn_region_path, name, action_lib_pc_spawn_region_path)
				tab_next()
				
				tab_control_dragger()
				draw_dragger("particleeditorspawnregionpathradius", dx, dy, 64, temp_edit.pc_spawn_region_path_radius, temp_edit.pc_spawn_region_path_radius / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_path_radius, action_lib_pc_spawn_region_path_radius)
				tab_next()
				
				break
			}
		}
		
		draw_divide(dx, dy, dw)
		dy += 8
	}
	
	// Bounding box
	tab_control_menu()
	draw_button_menu("particleeditorboundingbox", e_menu.LIST, dx, dy, dw, 24, temp_edit.pc_bounding_box_type, text_get("particleeditorboundingboxtype" + temp_edit.pc_bounding_box_type), action_lib_pc_bounding_box_type)
	tab_next()
	
	if (temp_edit.pc_bounding_box_type = "ground")
	{
		tab_control_dragger()
		draw_dragger("particleeditorboundingboxground" + (setting_z_is_up ? "z" : "y"), dx, dy, 64, temp_edit.pc_bounding_box_ground_z, 0.1, -no_limit, no_limit, 0, 0, tab.tbx_bounding_box_ground_z, action_lib_pc_bounding_box_ground_z)
		tab_next()
	}
	else if (temp_edit.pc_bounding_box_type = "custom")
	{
		// "From" position
		axis_edit = X
		textfield_group_add("particleeditorboundingboxfromx", temp_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_xstart, null, 1, -no_limit, temp_edit.pc_bounding_box_custom_end[axis_edit])
		axis_edit = sn
		textfield_group_add("particleeditorboundingboxfromy", temp_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_ystart, null, 1, -no_limit, temp_edit.pc_bounding_box_custom_end[axis_edit])
		axis_edit = ud
		textfield_group_add("particleeditorboundingboxfromz", temp_edit.pc_bounding_box_custom_start[axis_edit], -100, action_lib_pc_bounding_box_custom_start, axis_edit, tab.tbx_bounding_box_custom_zstart, null, 1, -no_limit, temp_edit.pc_bounding_box_custom_end[axis_edit])
		
		tab_control_textfield_group()
		draw_textfield_group("particleeditorboundingboxcustomfrom", dx, dy, dw, 1, 0, no_limit, 0, true, true, 1)
		tab_next()
		
		// "To" position
		axis_edit = X
		textfield_group_add("particleeditorboundingboxtox", temp_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_xend, null, 1, temp_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		axis_edit = sn
		textfield_group_add("particleeditorboundingboxtoy", temp_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_yend, null, 1, temp_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		axis_edit = ud
		textfield_group_add("particleeditorboundingboxtoz", temp_edit.pc_bounding_box_custom_end[axis_edit], 100, action_lib_pc_bounding_box_custom_end, axis_edit, tab.tbx_bounding_box_custom_zend, null, 1, temp_edit.pc_bounding_box_custom_start[axis_edit], no_limit)
		
		tab_control_textfield_group()
		draw_textfield_group("particleeditorboundingboxcustomto", dx, dy, dw, 1, 0, no_limit, 0, true, true, 1)
		tab_next()
		
		tab_control_switch()
		draw_switch("particleeditorboundingboxrelative", dx, dy, temp_edit.pc_bounding_box_relative, action_lib_pc_bounding_box_relative)
		tab_next()
	}
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	#endregion
	#region DESTRUCTION
	
	tab_control(16)
	draw_label(text_get("particleeditordestruction"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// "Destroy when..." label
	tab_control(16)
	draw_label(text_get("particleeditordestroy"), dx, dy + 8, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	tab_next()
	
	// Destroy after animation
	tab_control_checkbox()
	draw_checkbox("particleeditordestroyanimationfinish", dx, dy, temp_edit.pc_destroy_at_animation_finish, action_lib_pc_destroy_at_animation_finish)
	tab_next(false)
	
	// Destroy at bounding box
	tab_control_checkbox()
	draw_checkbox("particleeditordestroyboundingboxtoggle", dx, dy, temp_edit.pc_destroy_at_bounding_box, action_lib_pc_destroy_at_bounding_box)
	tab_next(false)
	
	// Destroy at amount
	tab_control_checkbox()
	draw_checkbox("particleeditordestroyamount", dx, dy, temp_edit.pc_destroy_at_amount, action_lib_pc_destroy_at_amount)
	
	wid = text_max_width("particleeditordestroyamount") + 8 + 26
	
	if (wid + dragger_width + 8 > dw)
	{
		tab_next(false)
		tab_control_dragger()
		wid = 0
	}
	
	draw_dragger("particleeditordestroyamountval", dx + wid, dy, 64, temp_edit.pc_destroy_at_amount_val, 1 / 4, 0, no_limit, 200, 1, tab.tbx_destroy_at_amount_val, action_lib_pc_destroy_at_amount_val, wid, false)
	
	tab_next(wid = 0)
	
	// Destroy at a time
	tab_control_checkbox()
	draw_checkbox("particleeditordestroytime", dx, dy, temp_edit.pc_destroy_at_time, action_lib_pc_destroy_at_time)
	tab_next(!temp_edit.pc_destroy_at_time)
	
	if (temp_edit.pc_destroy_at_time)
	{
		tab_template_editor_particles_value("particleeditordestroylifespan", 
			temp_edit.pc_destroy_at_time_seconds, temp_edit.pc_destroy_at_time_israndom, temp_edit.pc_destroy_at_time_random_min, temp_edit.pc_destroy_at_time_random_max, 
			1 / 20, 0, no_limit, array(5, 5, 10), 0, 
			array(tab.tbx_destroy_at_time_seconds, tab.tbx_destroy_at_time_random), 
			array(action_lib_pc_destroy_at_time_seconds, action_lib_pc_destroy_at_time_israndom, action_lib_pc_destroy_at_time_random_min, action_lib_pc_destroy_at_time_random_max),
			null, false, suffix)
	}
	
	#endregion
	#region PARTICLE EMITTERS
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particleeditoremitters"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	tab_control_sortlist(6)
	sortlist_draw(tab.type_list, dx, dy, dw, tab_control_h, ptype_edit, false)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("particleeditortypeadd", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltipparticlesadd"))
		action_lib_pc_type_add()
	
	if (draw_button_icon("particleeditortypeduplicate", dx + 28, dy, 24, 24, false, icons.DUPLICATE, null, ptype_edit = null, "tooltipparticlesduplicate"))
		action_lib_pc_type_duplicate()
	
	if (draw_button_icon("particleeditortypedelete", dx + (28 * 2), dy, 24, 24, false, icons.DELETE, null, ptype_edit = null, "tooltipparticlesdelete"))
		action_lib_pc_type_remove()
		
	tab_next()
	
	if (ptype_edit = null)
		return 0
	
	capwid = text_caption_width("particleeditortypename", 
							"particleeditortypespawnrate", 
							"particleeditortypetemp", 
							"particleeditortypespritetex", 
							"particleeditortypespriteteximage",
							"particleeditortypespritetemplatepack", 
							"particleeditortypespritetemplate",
							"particleeditortypetext")
	
	// Name
	tab.tbx_type_name.text = ptype_edit.name
	
	tab_control_dragger()
	draw_textfield("particleeditortypename", dx, dy, dw, 24, tab.tbx_type_name, action_lib_pc_type_name, "", "left")
	tab_next()
	
	// Spawn rate
	if (ds_list_size(temp_edit.pc_type_list) > 1)
	{
		tab_control_meter()
		draw_meter("particleeditortypespawnrate", dx, dy, dw, ptype_edit.spawn_rate * 100, 0, 100, 100 / ds_list_size(temp_edit.pc_type_list), 1, tab.tbx_type_spawn_rate, action_lib_pc_type_spawn_rate)
		tab_next()
	}
	
	// Template
	tab_control_menu()
	
	text = text_get("particleeditortypespritesheet")
	if (ptype_edit.temp = particle_template)
		text = text_get("particleeditortypetemplate")
	if (ptype_edit.temp)
		text = ptype_edit.temp.display_name
	
	draw_button_menu("particleeditortypetemp", e_menu.LIST, dx, dy, dw, 24, ptype_edit.temp, text, action_lib_pc_type_temp)
	tab_next()
	
	// Sprite
	if (ptype_edit.temp < 0)
	{
		// Sprite sheet
		if (ptype_edit.temp = particle_sheet)
		{
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu("particleeditortypespritetex", e_menu.LIST, dx, dy, dw, ui_large_height, ptype_edit.sprite_tex, ptype_edit.sprite_tex.display_name, action_lib_pc_type_sprite_tex, false, ptype_edit.sprite_tex.particles_texture[ptype_edit.sprite_tex_image])
			tab_next()
			
			// Image
			if (ptype_edit.sprite_tex.type = e_res_type.PACK)
			{
				tab_control_togglebutton()
				togglebutton_add("particleeditortypespriteteximage1", null, 0, ptype_edit.sprite_tex_image = 0, action_lib_pc_type_sprite_tex_image)
				togglebutton_add("particleeditortypespriteteximage2", null, 1, ptype_edit.sprite_tex_image = 1, action_lib_pc_type_sprite_tex_image)
				draw_togglebutton("particleeditortypespriteteximage", dx, dy)
				tab_next()
			}
			
			// Frames
			tab_template_editor_particles_framebox()
			
			// Frame width / height
			tab.tbx_type_sprite_frame_width.suffix = text_get("particleeditorpixels")
			tab.tbx_type_sprite_frame_height.suffix = text_get("particleeditorpixels")
			
			tab_control_textfield_group()
			textfield_group_add("particleeditortypespriteframewidth", ptype_edit.sprite_frame_width, 8, action_lib_pc_type_sprite_frame_width, axis_edit, tab.tbx_type_sprite_frame_width)
			textfield_group_add("particleeditortypespriteframeheight", ptype_edit.sprite_frame_height, 8, action_lib_pc_type_sprite_frame_height, axis_edit, tab.tbx_type_sprite_frame_height)
			draw_textfield_group("particleeditortypespriteframesize", dx, dy, dw, 1 / 10, 1, no_limit, 1, true, true, 1)
			tab_next()
			
			// Frames
			tab_control_textfield_group()
			textfield_group_add("particleeditortypespriteframestart", ptype_edit.sprite_frame_start, 7, action_lib_pc_type_sprite_frame_start, axis_edit, tab.tbx_type_sprite_frame_start, null, 1 / 10, 0, no_limit, "particleeditorfrom")
			textfield_group_add("particleeditortypespriteframeend", ptype_edit.sprite_frame_end, 0, action_lib_pc_type_sprite_frame_end, axis_edit, tab.tbx_type_sprite_frame_end, null, 1 / 10, 0, no_limit, "particleeditorto")
			draw_textfield_group("particleeditortypespriteframeframes", dx, dy, dw, null, null, null, 1, true, 1)
			tab_next()
		}
		else // Particle template
		{
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu("particleeditortypespritetemplatepack", e_menu.LIST, dx, dy, dw, ui_large_height, ptype_edit.sprite_template_tex, ptype_edit.sprite_template_tex.display_name, action_lib_pc_type_sprite_template_tex, false, ptype_edit.sprite_template_tex.block_preview_texture)
			tab_next()
			
			// Template
			tab_control_menu()
			draw_button_menu("particleeditortypespritetemplate", e_menu.LIST, dx, dy, dw, 24, ptype_edit.sprite_template, text_get("particleeditortypespritetemplate" + ptype_edit.sprite_template), action_lib_pc_type_sprite_template, false)
			tab_next()
			
			// Still frame
			tab_control_switch()
			draw_switch("particleeditortypespritetemplatestillframe", dx, dy, ptype_edit.sprite_template_still_frame, action_lib_pc_type_sprite_template_still_frame)
			tab_next()
			
			// Random frame
			if (ptype_edit.sprite_template_still_frame)
			{
				tab_control_switch()
				draw_switch("particleeditortypespritetemplaterandomframe", dx, dy, ptype_edit.sprite_template_random_frame, action_lib_pc_type_sprite_template_random_frame)
				tab_next()
			}
			else
			{
				// Reverse template animation
				tab_control_switch()
				draw_switch("particleeditortypespritetemplatereverse", dx, dy, ptype_edit.sprite_template_reverse, action_lib_pc_type_sprite_template_reverse)
				tab_next()
			}
		}
		
		if (!(ptype_edit.sprite_template_still_frame && ptype_edit.temp = particle_template))
		{
			// Animation speed
			tab_template_editor_particles_value("particleeditortypespriteanimationspeed", 
				ptype_edit.sprite_animation_speed, ptype_edit.sprite_animation_speed_israndom, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_max, 
				1 / 25, 0, no_limit, array(5, 5, 10), 0, 
				array(tab.tbx_type_sprite_animation_speed, tab.tbx_type_sprite_animation_speed_random), 
				array(action_lib_pc_type_sprite_animation_speed, action_lib_pc_type_sprite_animation_speed_israndom, action_lib_pc_type_sprite_animation_speed_random_min, action_lib_pc_type_sprite_animation_speed_random_max),
				null, true, text_get("particleeditorfps"))
			
			// On animation end
			tab_control_togglebutton()
			togglebutton_add("particleeditortypespriteanimationonendstop", null, 0, ptype_edit.sprite_animation_onend = 0, action_lib_pc_type_sprite_animation_onend)
			togglebutton_add("particleeditortypespriteanimationonendloop", null, 1, ptype_edit.sprite_animation_onend = 1, action_lib_pc_type_sprite_animation_onend)
			togglebutton_add("particleeditortypespriteanimationonendreverse", null, 2, ptype_edit.sprite_animation_onend = 2, action_lib_pc_type_sprite_animation_onend)
			draw_togglebutton("particleeditortypespriteanimationonend", dx, dy)
			tab_next()
		}
		
		tab_template_editor_particles_preview()
	}
	else if (ptype_edit.temp.type = e_temp_type.TEXT) // Text field
	{
		tab_control(108)
		tab.tbx_type_text.text = ptype_edit.text
		draw_textfield("particleeditortypetext", dx, dy, dw, 88, tab.tbx_type_text, action_lib_pc_type_text, "", "top")
		tab_next()
	}
	
	#endregion
	#region TRAJECTORY
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particleeditortypetrajectory"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Launch angle
	tab_control_switch()
	
	if (draw_button_collapse("particleeditortypeangle", !ptype_edit.angle_collapse, null, true, "particleeditortypeangle"))
		ptype_edit.angle_collapse = !ptype_edit.angle_collapse
	
	tab_next()
	
	if (!ptype_edit.angle_collapse)
	{
		tab_collapse_start()
		
		capwid = (ptype_edit.angle_extend ? text_caption_width("particleeditortypeanglex", "particleeditortypeangley", "particleeditortypeanglez", 
															   "particleeditortypeanglespeed", "particleeditortypeanglespeedadd", "particleeditortypeanglespeedmul") :
										 text_caption_width("particleeditortypeanglexyz", "particleeditortypeanglespeed", "particleeditortypeanglespeedadd",
															"particleeditortypeanglespeedmul"))
		
		// Extend XYZ settings
		tab_control_switch()
		draw_switch("particleeditortypeangleextend", dx, dy, ptype_edit.angle_extend, action_lib_pc_type_angle_extend)
		tab_next()
		
		axis_edit = X
		tab_template_editor_particles_value("particleeditortypeangle" + (ptype_edit.angle_extend ? "x" : "xyz"), 
			ptype_edit.angle[X], ptype_edit.angle_israndom[X], ptype_edit.angle_random_min[X], ptype_edit.angle_random_max[X], 
			1 / 4, -no_limit, no_limit, array(0, 0, 360), 0, 
			array(tab.tbx_type_xangle, tab.tbx_type_xangle_random), 
			array(action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max), 
			capwid)
		
		if (ptype_edit.angle_extend)
		{
			axis_edit = sn
			tab_template_editor_particles_value("particleeditortypeangley", 
				ptype_edit.angle[sn], ptype_edit.angle_israndom[sn], ptype_edit.angle_random_min[sn], ptype_edit.angle_random_max[sn], 
				1 / 4, -no_limit, no_limit, array(0, 0, 360), 0, 
				array(tab.tbx_type_yangle, tab.tbx_type_yangle_random), 
				array(action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max), 
				capwid)
			
			axis_edit = ud
			tab_template_editor_particles_value("particleeditortypeanglez", 
				ptype_edit.angle[ud], ptype_edit.angle_israndom[ud], ptype_edit.angle_random_min[ud], ptype_edit.angle_random_max[ud], 
				1 / 4, -no_limit, no_limit, array(0, 0, 360), 0, 
				array(tab.tbx_type_zangle, tab.tbx_type_zangle_random), 
				array(action_lib_pc_type_angle, action_lib_pc_type_angle_israndom, action_lib_pc_type_angle_random_min, action_lib_pc_type_angle_random_max), 
				capwid)
		}
		
		tab_template_editor_particles_value("particleeditortypeanglespeed", 
			ptype_edit.angle_speed, ptype_edit.angle_speed_israndom, ptype_edit.angle_speed_random_min, ptype_edit.angle_speed_random_max, 
			1 / 4, -no_limit, no_limit, array(20, 0, 20), 0, 
			array(tab.tbx_type_angle_speed, tab.tbx_type_angle_speed_random), 
			array(action_lib_pc_type_angle_speed, action_lib_pc_type_angle_speed_israndom, action_lib_pc_type_angle_speed_random_min, action_lib_pc_type_angle_speed_random_max), 
			capwid, true, suffix)
		
		tab_template_editor_particles_value("particleeditortypeanglespeedadd", 
			ptype_edit.angle_speed_add, ptype_edit.angle_speed_add_israndom, ptype_edit.angle_speed_add_random_min, ptype_edit.angle_speed_add_random_max, 
			1 / 4, -no_limit, no_limit, array(0, -1, 1), 0, 
			array(tab.tbx_type_angle_speed_add, tab.tbx_type_angle_speed_add_random), 
			array(action_lib_pc_type_angle_speed_add, action_lib_pc_type_angle_speed_add_israndom, action_lib_pc_type_angle_speed_add_random_min, action_lib_pc_type_angle_speed_add_random_max), 
			capwid, true, suffix)
		
		tab_template_editor_particles_value("particleeditortypeanglespeedmul", 
			ptype_edit.angle_speed_mul, ptype_edit.angle_speed_mul_israndom, ptype_edit.angle_speed_mul_random_min, ptype_edit.angle_speed_mul_random_max, 
			1 / 4, 0, no_limit, array(1, 0.75, 0.9), 0, 
			array(tab.tbx_type_angle_speed_mul, tab.tbx_type_angle_speed_mul_random), 
			array(action_lib_pc_type_angle_speed_mul, action_lib_pc_type_angle_speed_mul_israndom, action_lib_pc_type_angle_speed_mul_random_min, action_lib_pc_type_angle_speed_mul_random_max), 
			capwid, true, suffix)
		
		tab_collapse_end()
	}
	
	// Speed
	tab_control_switch()
	
	if (draw_button_collapse("particleeditortypespeed", !ptype_edit.spd_collapse, null, true, "particleeditortypespeed"))
		ptype_edit.spd_collapse = !ptype_edit.spd_collapse
	
	tab_next()
	
	if (!ptype_edit.spd_collapse)
	{
		tab_collapse_start()
		
		capwid = (ptype_edit.spd_extend ? text_caption_width("particleeditortypespeedx", "particleeditortypespeedy", "particleeditortypespeedz", 
																"particleeditortypespeedxadd", "particleeditortypespeedyadd", "particleeditortypespeedzadd", 
																"particleeditortypespeedxmul", "particleeditortypespeedymul", "particleeditortypespeedzmul") :
											 text_caption_width("particleeditortypespeedxyz", "particleeditortypespeedxyzadd", "particleeditortypespeedxyzmul"))
		
		// Extend XYZ settings
		tab_control_switch()
		draw_switch("particleeditortypespeedextend", dx, dy, ptype_edit.spd_extend, action_lib_pc_type_spd_extend)
		tab_next()
		
		axis_edit = X
		tab_template_editor_particles_value("particleeditortypespeed" + (ptype_edit.spd_extend ? "x" : "xyz"), 
			ptype_edit.spd[X], ptype_edit.spd_israndom[X], ptype_edit.spd_random_min[X], ptype_edit.spd_random_max[X], 
			1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
			array(tab.tbx_type_xspd, tab.tbx_type_xspd_random), 
			array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
			capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_template_editor_particles_value("particleeditortypespeedy", 
				ptype_edit.spd[sn], ptype_edit.spd_israndom[sn], ptype_edit.spd_random_min[sn], ptype_edit.spd_random_max[sn], 
				1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
				array(tab.tbx_type_yspd, tab.tbx_type_yspd_random), 
				array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
				capwid, true, suffix)
			
			axis_edit = ud
			tab_template_editor_particles_value("particleeditortypespeedz", 
				ptype_edit.spd[ud], ptype_edit.spd_israndom[ud], ptype_edit.spd_random_min[ud], ptype_edit.spd_random_max[ud], 
				1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
				array(tab.tbx_type_zspd, tab.tbx_type_zspd_random), 
				array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
				capwid, true, suffix)
		}
		
		// Speed add
		axis_edit = X
		
		tab_template_editor_particles_value("particleeditortypespeed" + (ptype_edit.spd_extend ? "x" : "xyz") + "add", 
			ptype_edit.spd_add[X], ptype_edit.spd_add_israndom[X], ptype_edit.spd_add_random_min[X], ptype_edit.spd_add_random_max[X], 
			1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
			array(tab.tbx_type_xspd_add, tab.tbx_type_xspd_add_random), 
			array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
			capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_template_editor_particles_value("particleeditortypespeedyadd", 
				ptype_edit.spd_add[sn], ptype_edit.spd_add_israndom[sn], ptype_edit.spd_add_random_min[sn], ptype_edit.spd_add_random_max[sn], 
				1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
				array(tab.tbx_type_yspd_add, tab.tbx_type_yspd_add_random), 
				array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
				capwid, true, suffix)
			
			axis_edit = ud
			tab_template_editor_particles_value("particleeditortypespeedzadd", 
				ptype_edit.spd_add[ud], ptype_edit.spd_add_israndom[ud], ptype_edit.spd_add_random_min[ud], ptype_edit.spd_add_random_max[ud], 
				1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
				array(tab.tbx_type_zspd_add, tab.tbx_type_zspd_add_random), 
				array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
				capwid, true, suffix)
		}
		
		// Speed multiply
		axis_edit = X
		tab_template_editor_particles_value("particleeditortypespeed" + (ptype_edit.spd_extend ? "x" : "xyz") + "mul", 
			ptype_edit.spd_mul[X], ptype_edit.spd_mul_israndom[X], ptype_edit.spd_mul_random_min[X], ptype_edit.spd_mul_random_max[X], 
			1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
			array(tab.tbx_type_xspd_mul, tab.tbx_type_xspd_mul_random), 
			array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
			capwid, true, suffix)
		
		if (ptype_edit.spd_extend)
		{
			axis_edit = sn
			tab_template_editor_particles_value("particleeditortypespeedymul", 
				ptype_edit.spd_mul[sn], ptype_edit.spd_mul_israndom[sn], ptype_edit.spd_mul_random_min[sn], ptype_edit.spd_mul_random_max[sn], 
				1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
				array(tab.tbx_type_yspd_mul, tab.tbx_type_yspd_mul_random), 
				array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
				capwid, true, suffix)
			
			axis_edit = ud
			tab_template_editor_particles_value("particleeditortypespeedzmul", 
				ptype_edit.spd_mul[ud], ptype_edit.spd_mul_israndom[ud], ptype_edit.spd_mul_random_min[ud], ptype_edit.spd_mul_random_max[ud], 
				1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
				array(tab.tbx_type_zspd_mul, tab.tbx_type_zspd_mul_random), 
				array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
				capwid, true, suffix)
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
		draw_label(text_get("particleeditortyperotation"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
		tab_next()
		
		if (ptype_edit.temp)
		{
			// Launch angle
			tab_control_switch()
			
			if (draw_button_collapse("particleeditortyperotationinitial", !ptype_edit.rot_collapse, null, true, "particleeditortyperotationinitial"))
				ptype_edit.rot_collapse = !ptype_edit.rot_collapse
			
			tab_next()
			
			if (!ptype_edit.rot_collapse)
			{
				tab_collapse_start()
				
				// Rotation
				capwid = (ptype_edit.rot_extend ? text_caption_width("particleeditortyperotationx", "particleeditortyperotationy", "particleeditortyperotationz") :
													 text_caption_width("particleeditortyperotationxyz"))
				
				// Extend XYZ settings
				tab_control_switch()
				draw_switch("particleeditortyperotationextend", dx, dy, ptype_edit.rot_extend, action_lib_pc_type_rot_extend)
				tab_next()
				
				axis_edit = X
				tab_template_editor_particles_value("particleeditortyperotation" + (ptype_edit.rot_extend ? "x" : "xyz"), 
					ptype_edit.rot[X], ptype_edit.rot_israndom[X], ptype_edit.rot_random_min[X], ptype_edit.rot_random_max[X], 
					1 / 5, -no_limit, no_limit, array(0, 0, 360), 0, 
					array(tab.tbx_type_xrot, tab.tbx_type_xrot_random), 
					array(action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max), 
					capwid)
				
				if (ptype_edit.rot_extend)
				{
					axis_edit = sn
					tab_template_editor_particles_value("particleeditortyperotationy", 
						ptype_edit.rot[sn], ptype_edit.rot_israndom[sn], ptype_edit.rot_random_min[sn], ptype_edit.rot_random_max[sn], 
						1 / 5, -no_limit, no_limit, array(0, 0, 360), 0, 
						array(tab.tbx_type_yrot, tab.tbx_type_yrot_random), 
						array(action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max), 
						capwid)
					
					axis_edit = ud
					tab_template_editor_particles_value("particleeditortyperotationz", 
						ptype_edit.rot[ud], ptype_edit.rot_israndom[ud], ptype_edit.rot_random_min[ud], ptype_edit.rot_random_max[ud], 
						1 / 5, -no_limit, no_limit, array(0, 0, 360), 0, 
						array(tab.tbx_type_zrot, tab.tbx_type_zrot_random), 
						array(action_lib_pc_type_rot, action_lib_pc_type_rot_israndom, action_lib_pc_type_rot_random_min, action_lib_pc_type_rot_random_max), 
						capwid)
				}
				
				tab_collapse_end()
			}
			
			// Rotation speed
			tab_control_switch()
			
			if (draw_button_collapse("particleeditortyperotationspeed", !ptype_edit.rot_spd_collapse, null, true, "particleeditortyperotationspeed"))
				ptype_edit.rot_spd_collapse = !ptype_edit.rot_spd_collapse
			
			tab_next()
			
			if (!ptype_edit.rot_spd_collapse)
			{
				tab_collapse_start()
				
				capwid = (ptype_edit.rot_spd_extend ? text_caption_width("particleeditortyperotationspeedx", "particleeditortyperotationspeedy", "particleeditortyperotationspeedz", 
																			"particleeditortyperotationspeedxadd", "particleeditortyperotationspeedyadd", "particleeditortyperotationspeedzadd", 
																			"particleeditortyperotationspeedxmul", "particleeditortyperotationspeedymul", "particleeditortyperotationspeedzmul") :
														 text_caption_width("particleeditortyperotationspeedxyz", "particleeditortyperotationspeedxyzadd", "particleeditortyperotationspeedxyzmul"))
				
				// Extend XYZ settings
				tab_control_switch()
				draw_switch("particleeditortyperotationspeedextend", dx, dy, ptype_edit.rot_spd_extend, action_lib_pc_type_rot_spd_extend)
				tab_next()
				
				axis_edit = X
				tab_template_editor_particles_value("particleeditortyperotationspeed" + (ptype_edit.rot_spd_extend ? "x" : "xyz"), 
					ptype_edit.rot_spd[X], ptype_edit.rot_spd_israndom[X], ptype_edit.rot_spd_random_min[X], ptype_edit.rot_spd_random_max[X], 
					1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
					array(tab.tbx_type_xrot_spd, tab.tbx_type_xrot_spd_random), 
					array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
					capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_template_editor_particles_value("particleeditortyperotationspeedy", 
						ptype_edit.rot_spd[sn], ptype_edit.rot_spd_israndom[sn], ptype_edit.rot_spd_random_min[sn], ptype_edit.rot_spd_random_max[sn], 
						1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
						array(tab.tbx_type_yrot_spd, tab.tbx_type_yrot_spd_random), 
						array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
						capwid, true, suffix)
					
					axis_edit = ud
					tab_template_editor_particles_value("particleeditortyperotationspeedz", 
						ptype_edit.rot_spd[ud], ptype_edit.rot_spd_israndom[ud], ptype_edit.rot_spd_random_min[ud], ptype_edit.rot_spd_random_max[ud], 
						1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
						array(tab.tbx_type_zrot_spd, tab.tbx_type_zrot_spd_random), 
						array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
						capwid, true, suffix)
				}
				
				// Rotation speed add
				axis_edit = X
				tab_template_editor_particles_value("particleeditortyperotationspeed" + (ptype_edit.rot_spd_extend ? "x" : "xyz") + "add", 
					ptype_edit.rot_spd_add[X], ptype_edit.rot_spd_add_israndom[X], ptype_edit.rot_spd_add_random_min[X], ptype_edit.rot_spd_add_random_max[X], 
					1 / 10, -no_limit, no_limit, array(0, -10, 10), 0, 
					array(tab.tbx_type_xrot_spd_add, tab.tbx_type_xrot_spd_add_random), 
					array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
					capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_template_editor_particles_value("particleeditortyperotationspeedyadd", 
						ptype_edit.rot_spd_add[sn], ptype_edit.rot_spd_add_israndom[sn], ptype_edit.rot_spd_add_random_min[sn], ptype_edit.rot_spd_add_random_max[sn], 
						1 / 20, -no_limit, no_limit, array(0, -10, 10), 0, 
						array(tab.tbx_type_yrot_spd_add, tab.tbx_type_yrot_spd_add_random), 
						array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
						capwid, true, suffix)
					
					axis_edit = ud
					tab_template_editor_particles_value("particleeditortyperotationspeedzadd", 
						ptype_edit.rot_spd_add[ud], ptype_edit.rot_spd_add_israndom[ud], ptype_edit.rot_spd_add_random_min[ud], ptype_edit.rot_spd_add_random_max[ud], 
						1 / 10, -no_limit, no_limit, array(0, -10, 10), 0, 
						array(tab.tbx_type_zrot_spd_add, tab.tbx_type_zrot_spd_add_random), 
						array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
						capwid, true, suffix)
				}
				
				// Rotation speed multiplier
				axis_edit = X
				tab_template_editor_particles_value("particleeditortyperotationspeed" + (ptype_edit.rot_spd_extend ? "x" : "xyz") + "mul", 
					ptype_edit.rot_spd_mul[X], ptype_edit.rot_spd_mul_israndom[X], ptype_edit.rot_spd_mul_random_min[X], ptype_edit.rot_spd_mul_random_max[X], 
					1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
					array(tab.tbx_type_xrot_spd_mul, tab.tbx_type_xrot_spd_mul_random), 
					array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
					capwid, true, suffix)
				
				if (ptype_edit.rot_spd_extend)
				{
					axis_edit = sn
					tab_template_editor_particles_value("particleeditortyperotationspeedymul", 
						ptype_edit.rot_spd_mul[sn], ptype_edit.rot_spd_mul_israndom[sn], ptype_edit.rot_spd_mul_random_min[sn], ptype_edit.rot_spd_mul_random_max[sn], 
						1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
						array(tab.tbx_type_yrot_spd_mul, tab.tbx_type_yrot_spd_mul_random), 
						array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
						capwid, true, suffix)
					
					axis_edit = ud
					tab_template_editor_particles_value("particleeditortyperotationspeedzmul", 
						ptype_edit.rot_spd_mul[ud], ptype_edit.rot_spd_mul_israndom[ud], ptype_edit.rot_spd_mul_random_min[ud], ptype_edit.rot_spd_mul_random_max[ud], 
						1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
						array(tab.tbx_type_zrot_spd_mul, tab.tbx_type_zrot_spd_mul_random), 
						array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
						capwid, true, suffix)
				}
				
				tab_collapse_end()
			}
		}
		
		// Sprite angle
		if (ptype_edit.temp = particle_sheet || ptype_edit.temp = particle_template)
		{
			capwid = text_caption_width("particleeditortypespriteangle", "particleeditortypespriteangleadd")
			
			tab_template_editor_particles_value("particleeditortypespriteangle", 
				ptype_edit.sprite_angle, ptype_edit.sprite_angle_israndom, ptype_edit.sprite_angle_random_min, ptype_edit.sprite_angle_random_max, 
				1 / 5, 0, no_limit, array(0, 0, 360), 0, 
				array(tab.tbx_type_sprite_angle, tab.tbx_type_sprite_angle_random), 
				array(action_lib_pc_type_sprite_angle, action_lib_pc_type_sprite_angle_israndom, action_lib_pc_type_sprite_angle_random_min, action_lib_pc_type_sprite_angle_random_max), 
				capwid)
			
			// Angle change
			tab_template_editor_particles_value("particleeditortypespriteangleadd", 
				ptype_edit.sprite_angle_add, ptype_edit.sprite_angle_add_israndom, ptype_edit.sprite_angle_add_random_min, ptype_edit.sprite_angle_add_random_max, 
				1 / 10, -no_limit, no_limit, array(0, -90, 90), 0, 
				array(tab.tbx_type_sprite_angle_add, tab.tbx_type_sprite_angle_add_random), 
				array(action_lib_pc_type_sprite_angle_add, action_lib_pc_type_sprite_angle_add_israndom, action_lib_pc_type_sprite_angle_add_random_min, action_lib_pc_type_sprite_angle_add_random_max), 
				capwid, true, suffix)
		}
	}
	
	#endregion
	#region SCALE
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particleeditortypescale"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Scale
	capwid = text_caption_width("particleeditortypeinitialscale", "particleeditortypescaleadd")
	
	tab_template_editor_particles_value("particleeditortypeinitialscale", 
		ptype_edit.scale, ptype_edit.scale_israndom, ptype_edit.scale_random_min, ptype_edit.scale_random_max, 
		1 / 100, 0, no_limit, array(1, 0.5, 2), 0, 
		array(tab.tbx_type_scale, tab.tbx_type_scale_random), 
		array(action_lib_pc_type_scale, action_lib_pc_type_scale_israndom, action_lib_pc_type_scale_random_min, action_lib_pc_type_scale_random_max), 
		capwid)
	
	// Scale change
	tab_template_editor_particles_value("particleeditortypescaleadd", 
		ptype_edit.scale_add, ptype_edit.scale_add_israndom, ptype_edit.scale_add_random_min, ptype_edit.scale_add_random_max, 
		1 / 100, -no_limit, no_limit, array(0, -0.2, -0.1), 0, 
		array(tab.tbx_type_scale_add, tab.tbx_type_scale_add_random), 
		array(action_lib_pc_type_scale_add, action_lib_pc_type_scale_add_israndom, action_lib_pc_type_scale_add_random_min, action_lib_pc_type_scale_add_random_max), 
		capwid, true, suffix)
	dy += 10
	
	#endregion
	#region APPEARANCE
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particleeditortypeappearance"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Alpha
	tab_control_meter()
	
	// Randomize alpha
	draw_button_icon("particleeditorrandomalpha", dx + dw - ui_small_height, dy, ui_small_height, ui_small_height, ptype_edit.alpha_israndom, icons.RANDOMIZE, action_lib_pc_type_alpha_israndom, false, "tooltipparticlesrandom")
	
	if (ptype_edit.alpha_israndom)
		draw_meter_range("particleeditortypeopacity", dx, dy, dw - 36, 0, 100, 1, round(ptype_edit.alpha_random_min * 100), round(ptype_edit.alpha_random_max * 100), 0, 100, tab.tbx_type_alpha, tab.tbx_type_alpha_random, action_lib_pc_type_alpha_random_min, action_lib_pc_type_alpha_random_max)
	else
		draw_meter("particleeditortypeopacity", dx, dy, dw - 36, round(ptype_edit.alpha * 100), 0, 100, 100, 1, tab.tbx_type_alpha, action_lib_pc_type_alpha)
	tab_next()
	
	// Alpha change
	tab_template_editor_particles_value("particleeditortypeopacityadd", 
		ptype_edit.alpha_add * 100, ptype_edit.alpha_add_israndom, ptype_edit.alpha_add_random_min * 100, ptype_edit.alpha_add_random_max * 100, 
		1 / 2, -no_limit, no_limit, array(0, -10, -5), 0, 
		array(tab.tbx_type_alpha_add, tab.tbx_type_alpha_add_random), 
		array(action_lib_pc_type_alpha_add, action_lib_pc_type_alpha_add_israndom, action_lib_pc_type_alpha_add_random_min, action_lib_pc_type_alpha_add_random_max),
		null, true, suffix)
	
	// Color
	var name, colwid;
	wid = (dw - 36)
	colwid = floor((wid - 8)/2)
	
	// Color mix
	tab_control_switch()
	draw_switch("particleeditortypecolormixenabled", dx, dy, ptype_edit.color_mix_enabled, action_lib_pc_type_color_mix_enabled)
	tab_next()
	
	if (ptype_edit.color_mix_enabled)
	{
		tab_control(20)
		draw_label(text_get("particleeditortypecolorstart"), dx, dy + 10, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		tab_next()
	}
	
	tab_control_color()
	draw_button_icon("particleeditorrandomcolor", dx + dw - ui_small_height, dy + (tab_control_h/2) - 12, ui_small_height, ui_small_height, ptype_edit.color_israndom, icons.RANDOMIZE, action_lib_pc_type_color_israndom, false, "tooltipparticlesrandom")
	if (ptype_edit.color_israndom)
	{
		name = ptype_edit.color_mix_enabled ? "particleeditortypecolorstartcolor1" : "particleeditortypecolorcolor1"
		draw_button_color(name, dx, dy, colwid, ptype_edit.color_random_start, c_gray, false, action_lib_pc_type_color_random_start)
		
		name = ptype_edit.color_mix_enabled ? "particleeditortypecolorstartcolor2" : "particleeditortypecolorcolor2"
		draw_button_color(name, dx + colwid + 8, dy, colwid, ptype_edit.color_random_end, c_white, false, action_lib_pc_type_color_random_end)
	}
	else
	{
		name = ptype_edit.color_mix_enabled ? "particleeditortypecolorstartcolor" : "particleeditortypecolorcolor"
		draw_button_color(name, dx, dy, wid, ptype_edit.color, c_white, false, action_lib_pc_type_color)
	}
	tab_next()
	
	if (ptype_edit.color_mix_enabled)
	{
		tab_control(20)
		draw_label(text_get("particleeditortypecolorend"), dx, dy + 10, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		tab_next()
		
		tab_control_color()
		draw_button_icon("particleeditorrandommixcolor", dx + dw - ui_small_height, dy + (tab_control_h/2) - 12, ui_small_height, ui_small_height, ptype_edit.color_mix_israndom, icons.RANDOMIZE, action_lib_pc_type_color_mix_israndom, false, "tooltipparticlesrandom")
		if (ptype_edit.color_mix_israndom)
		{
			draw_button_color("particleeditortypecolorendcolor1", dx, dy, colwid, ptype_edit.color_mix_random_start, c_gray, false, action_lib_pc_type_color_mix_random_start)
			draw_button_color("particleeditortypecolorendcolor2", dx + colwid + 8, dy, colwid, ptype_edit.color_mix_random_end, c_white, false, action_lib_pc_type_color_mix_random_end)
		}
		else
			draw_button_color("particleeditortypecolorendcolor", dx, dy, wid, ptype_edit.color_mix, c_black, false, action_lib_pc_type_color_mix)
		tab_next()
		
		tab_template_editor_particles_value("particleeditortypecolormixtime", 
			ptype_edit.color_mix_time, ptype_edit.color_mix_time_israndom, ptype_edit.color_mix_time_random_min, ptype_edit.color_mix_time_random_max, 
			1 / 20, 0, no_limit, array(3, 1, 5), 0, 
			array(tab.tbx_type_color_mix_time, tab.tbx_type_color_mix_time_random), 
			array(action_lib_pc_type_color_mix_time, action_lib_pc_type_color_mix_time_israndom, action_lib_pc_type_color_mix_time_random_min, action_lib_pc_type_color_mix_time_random_max),
			null, true, suffix)
	}
	
	#endregion
	#region SIMULATION
	
	draw_divide(content_x, dy, dividew)
	dy += 12
	
	tab_control(16)
	draw_label(text_get("particleeditortypesimulation"), dx, dy + 8, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	tab_next()
	
	// Spawn region
	tab_control_switch()
	draw_switch("particleeditortypespawnregion", dx, dy, ptype_edit.spawn_region, action_lib_pc_type_spawn_region)
	tab_next()
	
	// Orbit attractor
	tab_control_switch()
	draw_switch("particleeditortypeorbit", dx, dy, ptype_edit.orbit, action_lib_pc_type_orbit)
	tab_next()
	
	tab_control_switch()
	draw_switch("particleeditortypeboundingbox", dx, dy, ptype_edit.bounding_box, action_lib_pc_type_bounding_box)
	tab_next()
	
	// Bounding box
	if (ptype_edit.bounding_box)
	{
		// Bounce
		tab_control_switch()
		draw_switch("particleeditortypebounce", dx, dy + 1, ptype_edit.bounce, action_lib_pc_type_bounce)
		tab_next()
		
		if (ptype_edit.bounce)
		{
			tab_control_dragger()
			draw_dragger("particleeditortypebouncefactor", dx, dy, 64, ptype_edit.bounce_factor, 1 / 100, 0, no_limit, 0.5, 0, tab.tbx_type_bounce_factor, action_lib_pc_type_bounce_factor)
			tab_next()
		}
	}
	
	#endregion
}
