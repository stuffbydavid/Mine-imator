/// tab_template_editor_particles()

var capwid, setx, wid, listh, text;
var sn, ud;
sn = test(setting_z_is_up, Y, Z) // South/north axis
ud = test(setting_z_is_up, Z, Y) // Up/down axis

if (content_direction = e_scroll.HORIZONTAL)
	dw = min(dw, 350)

// Settings
setx = dx
tab_control(24)
tip_set_shortcut(setting_key_spawn_particles, setting_key_spawn_particles_control)
if (!temp_edit.pc_spawn_constant)
{
	if (draw_button_normal("particleeditorspawn", setx, dy, 60, 24))
		action_lib_pc_spawn()
	setx += 68
}
tip_set_shortcut(setting_key_clear_particles, setting_key_clear_particles_control)
if (draw_button_normal("particleeditorclear", setx, dy, 60, 24))
	action_lib_pc_clear()
setx += 68

tip_set(text_get("particleeditorcounttip"), setx, dy, dw - (setx - dx) - 50, 24)
draw_label(text_get("particleeditorcount", string(instance_number(obj_particle))), setx, dy + 12, fa_left, fa_middle)

if (draw_button_normal("particleeditorimport", dx + dw - 50, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.browse))
	action_lib_pc_open()
if (draw_button_normal("particleeditorexport", dx + dw - 25, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.export))
	particles_save()

tab_next()

tab_control(4)
draw_separator_horizontal(dx, dy, dw)
tab_next()

// Spawn amount
tab_control_checkbox()
draw_checkbox("particleeditorspawnconstant", dx, dy, temp_edit.pc_spawn_constant, action_lib_pc_spawn_constant)
tab_next()

tab_control_dragger()
tab.tbx_spawn_amount.suffix = test(temp_edit.pc_spawn_constant, " " + text_get("particleeditorperminute"), "")
draw_dragger("particleeditorspawnamount", dx, dy, dw, temp_edit.pc_spawn_amount, test(temp_edit.pc_spawn_constant, 2, 1 / 5), 1, no_limit, 100, 1, tab.tbx_spawn_amount, action_lib_pc_spawn_amount)
tab_next()

dy += 10

// Spawn region
tab_control_checkbox()
draw_checkbox("particleeditorspawnregion", dx, dy, temp_edit.pc_spawn_region_use, action_lib_pc_spawn_region_use)
tab_next()
if (temp_edit.pc_spawn_region_use)
{
	var icon;
	switch (temp_edit.pc_spawn_region_type)
	{
		case "sphere":	icon = icons.sphere		break
		case "cube":	icon = icons.cube		break
		case "box":		icon = icons.box		break
	}
	
	tab_control(32)
	draw_button_menu("particleeditorspawnregiontype", e_menu.LIST, dx, dy, dw, 32, temp_edit.pc_spawn_region_type, text_get("particleeditorspawnregiontype" + temp_edit.pc_spawn_region_type), action_lib_pc_spawn_region_type, spr_icons, icon)
	tab_next()
	
	switch (temp_edit.pc_spawn_region_type)
	{
		case "sphere":
			tab_control_dragger()
			draw_dragger("particleeditorspawnregionsphereradius", dx, dy, dw, temp_edit.pc_spawn_region_sphere_radius, temp_edit.pc_spawn_region_sphere_radius / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_sphere_radius, action_lib_pc_spawn_region_sphere_radius)
			tab_next()
			break
			
		case "cube":
			tab_control_dragger()
			draw_dragger("particleeditorspawnregioncubesize", dx, dy, dw, temp_edit.pc_spawn_region_cube_size, temp_edit.pc_spawn_region_cube_size / 100, 0, no_limit, 100, 0, tab.tbx_spawn_region_cube_size, action_lib_pc_spawn_region_cube_size)
			tab_next()
			break
			
		case "box":
			capwid = text_caption_width("particleeditorspawnregionboxxsize", "particleeditorspawnregionboxysize", "particleeditorspawnregionboxzsize")
			axis_edit = X
			tab_control_dragger()
			draw_dragger("particleeditorspawnregionboxxsize", dx, dy, dw, temp_edit.pc_spawn_region_box_size[X], temp_edit.pc_spawn_region_box_size[X] / 100, 0, no_limit, 200, 0, tab.tbx_spawn_region_box_xsize, action_lib_pc_spawn_region_box_size)
			tab_next()
			
			axis_edit = sn
			tab_control_dragger()
			draw_dragger("particleeditorspawnregionboxysize", dx, dy, dw, temp_edit.pc_spawn_region_box_size[sn], temp_edit.pc_spawn_region_box_size[sn] / 100, 0, no_limit, 200, 0, tab.tbx_spawn_region_box_ysize, action_lib_pc_spawn_region_box_size)
			tab_next()
			
			axis_edit = ud
			tab_control_dragger()
			draw_dragger("particleeditorspawnregionboxzsize", dx, dy, dw, temp_edit.pc_spawn_region_box_size[ud], temp_edit.pc_spawn_region_box_size[ud] / 100, 0, no_limit, 200, 0, tab.tbx_spawn_region_box_zsize, action_lib_pc_spawn_region_box_size)
			tab_next()
			
			break
	}
}
dy += 10

// Bounding box
tab_control(14)
draw_label(text_get("particleeditorboundingbox") + ":", dx, dy)
tab_next()

tab_control_checkbox()
draw_radiobutton("particleeditorboundingboxtypenone", dx, dy, 0, temp_edit.pc_bounding_box_type = 0, action_lib_pc_bounding_box_type)
draw_radiobutton("particleeditorboundingboxtypeground", dx + floor(dw * 0.2), dy, 1, temp_edit.pc_bounding_box_type = 1, action_lib_pc_bounding_box_type)
draw_radiobutton("particleeditorboundingboxtypespawn", dx + floor(dw * 0.42), dy, 2, temp_edit.pc_bounding_box_type = 2, action_lib_pc_bounding_box_type)
draw_radiobutton("particleeditorboundingboxtypecustom", dx + floor(dw * 0.75), dy, 3, temp_edit.pc_bounding_box_type = 3, action_lib_pc_bounding_box_type)
tab_next()

if (temp_edit.pc_bounding_box_type = 1)
{
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxground" + test(setting_z_is_up, "z", "y"), dx, dy, dw, temp_edit.pc_bounding_box_ground_z, 0.1, -no_limit, no_limit, 0, 0, tab.tbx_bounding_box_ground_z, action_lib_pc_bounding_box_ground_z)
	tab_next()
}
else if (temp_edit.pc_bounding_box_type = 3)
{
	capwid = text_caption_width("particleeditorboundingboxcustomxstart", "particleeditorboundingboxcustomxstart", "particleeditorboundingboxcustomzstart", 
							  "particleeditorboundingboxcustomxend", "particleeditorboundingboxcustomyend", "particleeditorboundingboxcustomzend")
	
	axis_edit = X
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomxstart", dx, dy, dw, temp_edit.pc_bounding_box_custom_start[X], 1, -no_limit, temp_edit.pc_bounding_box_custom_end[X], -100, 0, tab.tbx_bounding_box_custom_xstart, action_lib_pc_bounding_box_custom_start, capwid)
	tab_next()
	
	axis_edit = sn
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomystart", dx, dy, dw, temp_edit.pc_bounding_box_custom_start[sn], 1, -no_limit, temp_edit.pc_bounding_box_custom_end[sn], -100, 0, tab.tbx_bounding_box_custom_ystart, action_lib_pc_bounding_box_custom_start, capwid)
	tab_next()
	
	axis_edit = ud
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomzstart", dx, dy, dw, temp_edit.pc_bounding_box_custom_start[ud], 1, -no_limit, temp_edit.pc_bounding_box_custom_end[ud], -100, 0, tab.tbx_bounding_box_custom_zstart, action_lib_pc_bounding_box_custom_start, capwid)
	tab_next()
	
	axis_edit = X
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomxend", dx, dy, dw, temp_edit.pc_bounding_box_custom_end[X], 1, temp_edit.pc_bounding_box_custom_start[X], no_limit, 100, 0, tab.tbx_bounding_box_custom_xend, action_lib_pc_bounding_box_custom_end, capwid)
	tab_next()
	
	axis_edit = sn
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomyend", dx, dy, dw, temp_edit.pc_bounding_box_custom_end[sn], 1, temp_edit.pc_bounding_box_custom_start[sn], no_limit, 100, 0, tab.tbx_bounding_box_custom_yend, action_lib_pc_bounding_box_custom_end, capwid)
	tab_next()
	
	axis_edit = ud
	tab_control_dragger()
	draw_dragger("particleeditorboundingboxcustomzend", dx, dy, dw, temp_edit.pc_bounding_box_custom_end[ud], 1, temp_edit.pc_bounding_box_custom_start[ud], no_limit, 100, 0, tab.tbx_bounding_box_custom_zend, action_lib_pc_bounding_box_custom_end, capwid)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("particleeditorboundingboxrelative", dx, dy, temp_edit.pc_bounding_box_relative, action_lib_pc_bounding_box_relative)
	tab_next()
}
dy += 10

// Destroy
tab_control(14)
draw_label(text_get("particleeditordestroy"), dx, dy)
tab_next()

// Destroy after animation
tab_control_checkbox()
draw_checkbox("particleeditordestroyatanimationfinish", dx, dy, temp_edit.pc_destroy_at_animation_finish, action_lib_pc_destroy_at_animation_finish)
tab_next()

// Destroy at amount
tab_control_checkbox()
draw_checkbox("particleeditordestroyatamount", dx, dy, temp_edit.pc_destroy_at_amount, action_lib_pc_destroy_at_amount)
if (temp_edit.pc_destroy_at_amount)
{
	wid = text_max_width("particleeditordestroyatamount") + 5
	draw_dragger("particleeditordestroyatamountval", dx + wid, dy - 1, dw - wid, temp_edit.pc_destroy_at_amount_val, 1 / 4, 0, no_limit, 200, 1, tab.tbx_destroy_at_amount_val, action_lib_pc_destroy_at_amount_val)
}
tab_next()

// Destroy at a time
tab_control_checkbox()
draw_checkbox("particleeditordestroyattimetoggle", dx, dy, temp_edit.pc_destroy_at_time, action_lib_pc_destroy_at_time)
tab_next()

tab.tbx_destroy_at_time_seconds.suffix = test(temp_edit.pc_destroy_at_time_israndom, "", " " + text_get("particleeditorseconds"))
tab.tbx_destroy_at_time_random.suffix = " " + text_get("particleeditorseconds")
if (temp_edit.pc_destroy_at_time)
{
	tab_template_editor_particles_value("particleeditordestroyattime", 
		temp_edit.pc_destroy_at_time_seconds, temp_edit.pc_destroy_at_time_israndom, temp_edit.pc_destroy_at_time_random_min, temp_edit.pc_destroy_at_time_random_max, 
		1 / 20, 0, no_limit, array(5, 5, 10), 0, 
		array(tab.tbx_destroy_at_time_seconds, tab.tbx_destroy_at_time_random), 
		array(action_lib_pc_destroy_at_time_seconds, action_lib_pc_destroy_at_time_israndom, action_lib_pc_destroy_at_time_random_min, action_lib_pc_destroy_at_time_random_max))
}

// Type list
tab_control(14)
draw_label(text_get("particleeditortypes") + ":", dx, dy)
tab_next()
listh = 172
if (content_direction = e_scroll.HORIZONTAL)
	listh = max(130, dh - (dy - dy_start) - 30)
if (tab_control(listh))
{
	listh = dh - (dy - dy_start - 18) - 30
	tab_control_h = listh
}
sortlist_draw(tab.type_list, dx, dy, dw, listh, ptype_edit)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("particleeditortypeadd", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.create))
	action_lib_pc_type_add()
	
if (draw_button_normal("particleeditortyperemove", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, (ptype_edit != null), icons.remove))
	action_lib_pc_type_remove()
	
if (draw_button_normal("particleeditortypeduplicate", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, (ptype_edit != null), icons.duplicate))
	action_lib_pc_type_duplicate()
	
tab_next()

if (!ptype_edit)
	return 0
	
capwid = text_caption_width("particleeditortypename", 
					  "particleeditortypespawnrate", 
					  "particleeditortypetemp", 
					  "particleeditortypespritetex", 
					  "particleeditortypespriteteximage", 
					  "particleeditortypetext")
					  
// Name
tab_control_inputbox()
tab.tbx_type_name.text = ptype_edit.name
draw_inputbox("particleeditortypename", dx, dy, dw, "", tab.tbx_type_name, action_lib_pc_type_name, capwid)
tab_next()

// Spawn rate
if (temp_edit.pc_types > 1)
{
	tab_control_meter()
	draw_meter("particleeditortypespawnrate", dx, dy, dw, ptype_edit.spawn_rate * 100, 50, 0, 100, 100 / temp_edit.pc_types, 1, tab.tbx_type_spawn_rate, action_lib_pc_type_spawn_rate)
	tab_next()
}

// Template
tab_control(32)
text = text_get("particleeditortypesprite")
if (ptype_edit.temp)
	text = ptype_edit.temp.display_name
draw_button_menu("particleeditortypetemp", e_menu.LIST, dx, dy, dw, 32, ptype_edit.temp, text, action_lib_pc_type_temp, null, 0, capwid)
tab_next()

// Sprite
if (!ptype_edit.temp)
{
	// Texture
	tab_control(40)
	draw_button_menu("particleeditortypespritetex", e_menu.LIST, dx, dy, dw, 40, ptype_edit.sprite_tex, ptype_edit.sprite_tex.display_name, action_lib_pc_type_sprite_tex, ptype_edit.sprite_tex.particles_texture[ptype_edit.sprite_tex_image], null, capwid)
	tab_next()
	
	// Image
	tab_control_checkbox()
	draw_label(text_get("particleeditortypespriteteximage") + ":", dx, dy)
	if (ptype_edit.sprite_tex.type = "pack")
	{
		draw_radiobutton("particleeditortypespriteteximage1", dx + capwid, dy, 0, ptype_edit.sprite_tex_image = 0, action_lib_pc_type_sprite_tex_image)
		draw_radiobutton("particleeditortypespriteteximage2", dx + capwid + floor((dw - capwid) * 0.5), dy, 1, ptype_edit.sprite_tex_image = 1, action_lib_pc_type_sprite_tex_image)
	}
	tab_next()
	
	// Frames
	tab_template_editor_particles_framebox()
	
	// Frame width / height
	capwid = text_caption_width("particleeditortypespriteframewidth", 
							  "particleeditortypespriteframestart", 
							  "particleeditortypespriteframeend")
	
	tab.tbx_type_sprite_frame_width.suffix = " " + text_get("particleeditorpixels")
	tab.tbx_type_sprite_frame_height.suffix = " " + text_get("particleeditorpixels")
	
	tab_control_dragger()
	draw_dragger("particleeditortypespriteframewidth", dx, dy, dw, ptype_edit.sprite_frame_width, 1 / 10, 1, no_limit, 8, 1, tab.tbx_type_sprite_frame_width, action_lib_pc_type_sprite_frame_width, capwid)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("particleeditortypespriteframeheight", dx, dy, dw, ptype_edit.sprite_frame_height, 1 / 10, 1, no_limit, 8, 1, tab.tbx_type_sprite_frame_height, action_lib_pc_type_sprite_frame_height, capwid)
	tab_next()
	
	// Frames
	tab_control_dragger()
	draw_dragger("particleeditortypespriteframestart", dx, dy, dw, ptype_edit.sprite_frame_start, 1 / 10, 0, no_limit, 7, 1, tab.tbx_type_sprite_frame_start, action_lib_pc_type_sprite_frame_start, capwid)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("particleeditortypespriteframeend", dx, dy, dw, ptype_edit.sprite_frame_end, 1 / 10, 0, no_limit, 0, 1, tab.tbx_type_sprite_frame_end, action_lib_pc_type_sprite_frame_end, capwid)
	tab_next()
	
	// Animation speed
	tab.tbx_type_sprite_animation_speed.suffix = test(ptype_edit.sprite_animation_speed_israndom, "", " " + text_get("particleeditorfps"))
	tab.tbx_type_sprite_animation_speed_random.suffix = " " + text_get("particleeditorfps")
	tab_template_editor_particles_value("particleeditortypespriteanimationspeed", 
		ptype_edit.sprite_animation_speed, ptype_edit.sprite_animation_speed_israndom, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_max, 
		1 / 25, 0, no_limit, array(5, 5, 10), 0, 
		array(tab.tbx_type_sprite_animation_speed, tab.tbx_type_sprite_animation_speed_random), 
		array(action_lib_pc_type_sprite_animation_speed, action_lib_pc_type_sprite_animation_speed_israndom, action_lib_pc_type_sprite_animation_speed_random_min, action_lib_pc_type_sprite_animation_speed_random_max))
	
	// On animation end
	tab_control(16)
	draw_label(text_get("particleeditortypespriteanimationonend"), dx, dy)
	tab_next()
	
	tab_control_checkbox()
	draw_radiobutton("particleeditortypespriteanimationonendstop", dx, dy, 0, ptype_edit.sprite_animation_onend = 0, action_lib_pc_type_sprite_animation_onend)
	draw_radiobutton("particleeditortypespriteanimationonendloop", dx + floor(dw * 0.3), dy, 1, ptype_edit.sprite_animation_onend = 1, action_lib_pc_type_sprite_animation_onend)
	draw_radiobutton("particleeditortypespriteanimationonendreverse", dx + floor(dw * 0.6), dy, 2, ptype_edit.sprite_animation_onend = 2, action_lib_pc_type_sprite_animation_onend)
	tab_next()
	
	// Preview
	tab_control(14)
	draw_label(text_get("particleeditortypespriteanimationpreview") + ":", dx, dy)
	tab_next()
	
	tab_template_editor_particles_preview()
}
else if (ptype_edit.temp.type = "text") // Text field
{
	tab_control(110)
	tab.tbx_type_text.text = ptype_edit.text
	draw_inputbox("particleeditortypetext", dx, dy, dw, "", tab.tbx_type_text, action_lib_pc_type_text, capwid, 100)
	tab_next()
}

// Speed
capwid = test(ptype_edit.spd_extend, text_caption_width("particleeditortypespeedx", "particleeditortypespeedy", "particleeditortypespeedz", 
													   "particleeditortypespeedxadd", "particleeditortypespeedyadd", "particleeditortypespeedzadd", 
													   "particleeditortypespeedxmul", "particleeditortypespeedymul", "particleeditortypespeedzmul"), 
									 text_caption_width("particleeditortypespeedxyz", "particleeditortypespeedxyzadd", "particleeditortypespeedxyzmul"))
								  
tab_control(14)
if (draw_button_normal("particleeditortypespeedextend", dx, dy, 16, 16, e_button.CAPTION, ptype_edit.spd_extend, false, true, test(ptype_edit.spd_extend, icons.arrowdown, icons.arrowright)))
	action_lib_pc_type_spd_extend(!ptype_edit.spd_extend)
tab_next()

tab.tbx_type_xspd.suffix = test(ptype_edit.spd_israndom[X], "", text_get("particleeditorpersecond"))
tab.tbx_type_xspd_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_yspd.suffix = test(ptype_edit.spd_israndom[sn], "", text_get("particleeditorpersecond"))
tab.tbx_type_yspd_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_zspd.suffix = test(ptype_edit.spd_israndom[ud], "", text_get("particleeditorpersecond"))
tab.tbx_type_zspd_random.suffix = text_get("particleeditorpersecond")

axis_edit = X
tab_template_editor_particles_value("particleeditortypespeed" + test(ptype_edit.spd_extend, "x", "xyz"), 
	ptype_edit.spd[X], ptype_edit.spd_israndom[X], ptype_edit.spd_random_min[X], ptype_edit.spd_random_max[X], 
	1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
	array(tab.tbx_type_xspd, tab.tbx_type_xspd_random), 
	array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
	capwid)

if (ptype_edit.spd_extend)
{
	axis_edit = sn
	tab_template_editor_particles_value("particleeditortypespeedy", 
		ptype_edit.spd[sn], ptype_edit.spd_israndom[sn], ptype_edit.spd_random_min[sn], ptype_edit.spd_random_max[sn], 
		1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
		array(tab.tbx_type_yspd, tab.tbx_type_yspd_random), 
		array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
		capwid)
	
	axis_edit = ud
	tab_template_editor_particles_value("particleeditortypespeedz", 
		ptype_edit.spd[ud], ptype_edit.spd_israndom[ud], ptype_edit.spd_random_min[ud], ptype_edit.spd_random_max[ud], 
		1 / 4, -no_limit, no_limit, array(0, -20, 20), 0, 
		array(tab.tbx_type_zspd, tab.tbx_type_zspd_random), 
		array(action_lib_pc_type_spd, action_lib_pc_type_spd_israndom, action_lib_pc_type_spd_random_min, action_lib_pc_type_spd_random_max), 
		capwid)
}

// Speed add
tab.tbx_type_xspd_add.suffix = test(ptype_edit.spd_add_israndom[X], "", text_get("particleeditorpersecond"))
tab.tbx_type_xspd_add_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_yspd_add.suffix = test(ptype_edit.spd_add_israndom[sn], "", text_get("particleeditorpersecond"))
tab.tbx_type_yspd_add_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_zspd_add.suffix = test(ptype_edit.spd_add_israndom[ud], "", text_get("particleeditorpersecond"))
tab.tbx_type_zspd_add_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_xspd_mul.suffix = test(ptype_edit.spd_mul_israndom[X], "", text_get("particleeditorpersecond"))
tab.tbx_type_xspd_mul_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_yspd_mul.suffix = test(ptype_edit.spd_mul_israndom[sn], "", text_get("particleeditorpersecond"))
tab.tbx_type_yspd_mul_random.suffix = text_get("particleeditorpersecond")
tab.tbx_type_zspd_mul.suffix = test(ptype_edit.spd_mul_israndom[ud], "", text_get("particleeditorpersecond"))
tab.tbx_type_zspd_mul_random.suffix = text_get("particleeditorpersecond")
axis_edit = X

tab_template_editor_particles_value("particleeditortypespeed" + test(ptype_edit.spd_extend, "x", "xyz") + "add", 
	ptype_edit.spd_add[X], ptype_edit.spd_add_israndom[X], ptype_edit.spd_add_random_min[X], ptype_edit.spd_add_random_max[X], 
	1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
	array(tab.tbx_type_xspd_add, tab.tbx_type_xspd_add_random), 
	array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
	capwid)

if (ptype_edit.spd_extend)
{
	axis_edit = sn
	tab_template_editor_particles_value("particleeditortypespeedyadd", 
		ptype_edit.spd_add[sn], ptype_edit.spd_add_israndom[sn], ptype_edit.spd_add_random_min[sn], ptype_edit.spd_add_random_max[sn], 
		1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
		array(tab.tbx_type_yspd_add, tab.tbx_type_yspd_add_random), 
		array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
		capwid)
		
	axis_edit = ud
	tab_template_editor_particles_value("particleeditortypespeedzadd", 
		ptype_edit.spd_add[ud], ptype_edit.spd_add_israndom[ud], ptype_edit.spd_add_random_min[ud], ptype_edit.spd_add_random_max[ud], 
		1 / 10, -no_limit, no_limit, array(0, -1, 1), 0, 
		array(tab.tbx_type_zspd_add, tab.tbx_type_zspd_add_random), 
		array(action_lib_pc_type_spd_add, action_lib_pc_type_spd_add_israndom, action_lib_pc_type_spd_add_random_min, action_lib_pc_type_spd_add_random_max), 
		capwid)
}


// Speed multiply
axis_edit = X
tab_template_editor_particles_value("particleeditortypespeed" + test(ptype_edit.spd_extend, "x", "xyz") + "mul", 
	ptype_edit.spd_mul[X], ptype_edit.spd_mul_israndom[X], ptype_edit.spd_mul_random_min[X], ptype_edit.spd_mul_random_max[X], 
	1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
	array(tab.tbx_type_xspd_mul, tab.tbx_type_xspd_mul_random), 
	array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
	capwid)
	
if (ptype_edit.spd_extend)
{
	axis_edit = sn
	tab_template_editor_particles_value("particleeditortypespeedymul", 
		ptype_edit.spd_mul[sn], ptype_edit.spd_mul_israndom[sn], ptype_edit.spd_mul_random_min[sn], ptype_edit.spd_mul_random_max[sn], 
		1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
		array(tab.tbx_type_yspd_mul, tab.tbx_type_yspd_mul_random), 
		array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
		capwid)
		
	axis_edit = ud
	tab_template_editor_particles_value("particleeditortypespeedzmul", 
		ptype_edit.spd_mul[ud], ptype_edit.spd_mul_israndom[ud], ptype_edit.spd_mul_random_min[ud], ptype_edit.spd_mul_random_max[ud], 
		1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
		array(tab.tbx_type_zspd_mul, tab.tbx_type_zspd_mul_random), 
		array(action_lib_pc_type_spd_mul, action_lib_pc_type_spd_mul_israndom, action_lib_pc_type_spd_mul_random_min, action_lib_pc_type_spd_mul_random_max), 
		capwid)
}

dy += 10
if (ptype_edit.temp)
{
	// Rotation
	capwid = test(ptype_edit.rot_extend, text_caption_width("particleeditortyperotationx", "particleeditortyperotationy", "particleeditortyperotationz"), 
									  text_caption_width("particleeditortyperotationxyz"))
	tab_control(14)
	if (draw_button_normal("particleeditortyperotationextend", dx, dy, 16, 16, e_button.CAPTION, ptype_edit.rot_extend, false, true, test(ptype_edit.rot_extend, icons.arrowdown, icons.arrowright)))
		action_lib_pc_type_rot_extend(!ptype_edit.rot_extend)
	tab_next()
	
	tab.tbx_type_xrot_spd.suffix = "??" + test(ptype_edit.rot_spd_israndom[X], "", text_get("particleeditorpersecond"))
	tab.tbx_type_xrot_spd_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_yrot_spd.suffix = "??" + test(ptype_edit.rot_spd_israndom[sn], "", text_get("particleeditorpersecond"))
	tab.tbx_type_yrot_spd_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_zrot_spd.suffix = "??" + test(ptype_edit.rot_spd_israndom[ud], "", text_get("particleeditorpersecond"))
	tab.tbx_type_zrot_spd_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_xrot_spd_add.suffix = "??" + test(ptype_edit.rot_spd_add_israndom[X], "", text_get("particleeditorpersecond"))
	tab.tbx_type_xrot_spd_add_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_yrot_spd_add.suffix = "??" + test(ptype_edit.rot_spd_add_israndom[sn], "", text_get("particleeditorpersecond"))
	tab.tbx_type_yrot_spd_add_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_zrot_spd_add.suffix = "??" + test(ptype_edit.rot_spd_add_israndom[ud], "", text_get("particleeditorpersecond"))
	tab.tbx_type_zrot_spd_add_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_xrot_spd_mul.suffix = "??" + test(ptype_edit.rot_spd_mul_israndom[X], "", text_get("particleeditorpersecond"))
	tab.tbx_type_xrot_spd_mul_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_yrot_spd_mul.suffix = "??" + test(ptype_edit.rot_spd_mul_israndom[sn], "", text_get("particleeditorpersecond"))
	tab.tbx_type_yrot_spd_mul_random.suffix = "??" + text_get("particleeditorpersecond")
	tab.tbx_type_zrot_spd_mul.suffix = "??" + test(ptype_edit.rot_spd_mul_israndom[ud], "", text_get("particleeditorpersecond"))
	tab.tbx_type_zrot_spd_mul_random.suffix = "??" + text_get("particleeditorpersecond")
	
	axis_edit = X
	tab_template_editor_particles_value("particleeditortyperotation" + test(ptype_edit.rot_extend, "x", "xyz"), 
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
	
	// Rotation speed
	dy += 10
	capwid = test(ptype_edit.rot_spd_extend, text_caption_width("particleeditortyperotationspeedx", "particleeditortyperotationspeedy", "particleeditortyperotationspeedz", 
																"particleeditortyperotationspeedxadd", "particleeditortyperotationspeedyadd", "particleeditortyperotationspeedzadd", 
																"particleeditortyperotationspeedxmul", "particleeditortyperotationspeedymul", "particleeditortyperotationspeedzmul"), 
											 text_caption_width("particleeditortyperotationspeedxyz", "particleeditortyperotationspeedxyzadd", "particleeditortyperotationspeedxyzmul"))
										
	tab_control(14)
	if (draw_button_normal("particleeditortyperotationspeedextend", dx, dy, 16, 16, e_button.CAPTION, ptype_edit.rot_spd_extend, false, true, test(ptype_edit.rot_spd_extend, icons.arrowdown, icons.arrowright)))
		action_lib_pc_type_rot_spd_extend(!ptype_edit.rot_spd_extend)
	tab_next() 
	
	axis_edit = X
	tab_template_editor_particles_value("particleeditortyperotationspeed" + test(ptype_edit.rot_spd_extend, "x", "xyz"), 
		ptype_edit.rot_spd[X], ptype_edit.rot_spd_israndom[X], ptype_edit.rot_spd_random_min[X], ptype_edit.rot_spd_random_max[X], 
		1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
		array(tab.tbx_type_xrot_spd, tab.tbx_type_xrot_spd_random), 
		array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
		capwid)
		
	if (ptype_edit.rot_spd_extend)
	{
		axis_edit = sn
		tab_template_editor_particles_value("particleeditortyperotationspeedy", 
			ptype_edit.rot_spd[sn], ptype_edit.rot_spd_israndom[sn], ptype_edit.rot_spd_random_min[sn], ptype_edit.rot_spd_random_max[sn], 
			1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
			array(tab.tbx_type_yrot_spd, tab.tbx_type_yrot_spd_random), 
			array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
			capwid)
			
		axis_edit = ud
		tab_template_editor_particles_value("particleeditortyperotationspeedz", 
			ptype_edit.rot_spd[ud], ptype_edit.rot_spd_israndom[ud], ptype_edit.rot_spd_random_min[ud], ptype_edit.rot_spd_random_max[ud], 
			1 / 2, -no_limit, no_limit, array(0, -180, 180), 0, 
			array(tab.tbx_type_zrot_spd, tab.tbx_type_zrot_spd_random), 
			array(action_lib_pc_type_rot_spd, action_lib_pc_type_rot_spd_israndom, action_lib_pc_type_rot_spd_random_min, action_lib_pc_type_rot_spd_random_max), 
			capwid)
	}

	// Rotation speed add
	axis_edit = X
	tab_template_editor_particles_value("particleeditortype" + test(ptype_edit.rot_spd_extend, "x", "xyz") + "rotationspeedadd", 
		ptype_edit.rot_spd_add[X], ptype_edit.rot_spd_add_israndom[X], ptype_edit.rot_spd_add_random_min[X], ptype_edit.rot_spd_add_random_max[X], 
		1 / 10, -no_limit, no_limit, array(0, -10, 10), 0, 
		array(tab.tbx_type_xrot_spd_add, tab.tbx_type_xrot_spd_add_random), 
		array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
		capwid)
		
	if (ptype_edit.rot_spd_extend)
	{
		axis_edit = sn
		tab_template_editor_particles_value("particleeditortyperotationspeedyadd", 
			ptype_edit.rot_spd_add[sn], ptype_edit.rot_spd_add_israndom[sn], ptype_edit.rot_spd_add_random_min[sn], ptype_edit.rot_spd_add_random_max[sn], 
			1 / 20, -no_limit, no_limit, array(0, -10, 10), 0, 
			array(tab.tbx_type_yrot_spd_add, tab.tbx_type_yrot_spd_add_random), 
			array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
			capwid)
			
		axis_edit = ud
		tab_template_editor_particles_value("particleeditortyperotationspeedzadd", 
			ptype_edit.rot_spd_add[ud], ptype_edit.rot_spd_add_israndom[ud], ptype_edit.rot_spd_add_random_min[ud], ptype_edit.rot_spd_add_random_max[ud], 
			1 / 10, -no_limit, no_limit, array(0, -10, 10), 0, 
			array(tab.tbx_type_zrot_spd_add, tab.tbx_type_zrot_spd_add_random), 
			array(action_lib_pc_type_rot_spd_add, action_lib_pc_type_rot_spd_add_israndom, action_lib_pc_type_rot_spd_add_random_min, action_lib_pc_type_rot_spd_add_random_max), 
			capwid)
	}
	
	// Rotation speed multiplier
	axis_edit = X
	tab_template_editor_particles_value("particleeditortyperotationspeed" + test(ptype_edit.rot_spd_extend, "x", "xyz") + "mul", 
		ptype_edit.rot_spd_mul[X], ptype_edit.rot_spd_mul_israndom[X], ptype_edit.rot_spd_mul_random_min[X], ptype_edit.rot_spd_mul_random_max[X], 
		1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
		array(tab.tbx_type_xrot_spd_mul, tab.tbx_type_xrot_spd_mul_random), 
		array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
		capwid)
		
	if (ptype_edit.rot_spd_extend)
	{
		axis_edit = sn
		tab_template_editor_particles_value("particleeditortyperotationspeedymul", 
			ptype_edit.rot_spd_mul[sn], ptype_edit.rot_spd_mul_israndom[sn], ptype_edit.rot_spd_mul_random_min[sn], ptype_edit.rot_spd_mul_random_max[sn], 
			1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
			array(tab.tbx_type_yrot_spd_mul, tab.tbx_type_yrot_spd_mul_random), 
			array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
			capwid)
			
		axis_edit = ud
		tab_template_editor_particles_value("particleeditortyperotationspeedzmul", 
			ptype_edit.rot_spd_mul[ud], ptype_edit.rot_spd_mul_israndom[ud], ptype_edit.rot_spd_mul_random_min[ud], ptype_edit.rot_spd_mul_random_max[ud], 
			1 / 200, 0, no_limit, array(1, 0.75, 0.9), 0, 
			array(tab.tbx_type_zrot_spd_mul, tab.tbx_type_zrot_spd_mul_random), 
			array(action_lib_pc_type_rot_spd_mul, action_lib_pc_type_rot_spd_mul_israndom, action_lib_pc_type_rot_spd_mul_random_min, action_lib_pc_type_rot_spd_mul_random_max), 
			capwid)
	}
	dy += 10
}

// Scale
capwid = text_caption_width("particleeditortypescale", "particleeditortypescaleadd")

tab.tbx_type_scale_add.suffix = test(ptype_edit.scale_add_israndom, "", text_get("particleeditorpersecond"))
tab.tbx_type_scale_add_random.suffix = text_get("particleeditorpersecond")
	
tab_template_editor_particles_value("particleeditortypescale", 
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
	capwid)
dy += 10

// Alpha
capwid = text_caption_width("particleeditortypealpha", "particleeditortypealpharandom")

tab.tbx_type_alpha_add.suffix = "%" + test(ptype_edit.alpha_add_israndom, "", text_get("particleeditorpersecond"))
tab.tbx_type_alpha_add_random.suffix = "%" + text_get("particleeditorpersecond")

tab_control_meter()
draw_checkbox("particleeditorrandom", dx + dw - 75, dy + 4, ptype_edit.alpha_israndom, action_lib_pc_type_alpha_israndom)
if (ptype_edit.alpha_israndom)
{
	draw_meter("particleeditortypealpha", dx, dy, dw - 75, round(ptype_edit.alpha_random_min * 100), 60, 0, ptype_edit.alpha_random_max * 100, 0, 1, tab.tbx_type_alpha, action_lib_pc_type_alpha_random_min, capwid)
	tab_next()
	tab_control_meter()
	draw_meter("particleeditortypealpharandom", dx, dy, dw - 75, round(ptype_edit.alpha_random_max * 100), 60, ptype_edit.alpha_random_min * 100, 100, 100, 1, tab.tbx_type_alpha_random, action_lib_pc_type_alpha_random_max, 60, text_get("particleeditortypealphatip"))
}
else
	draw_meter("particleeditortypealpha", dx, dy, dw - 75, round(ptype_edit.alpha * 100), 60, 0, 100, 100, 1, tab.tbx_type_alpha, action_lib_pc_type_alpha)
tab_next()

// Alpha change
tab_template_editor_particles_value("particleeditortypealphaadd", 
	ptype_edit.alpha_add * 100, ptype_edit.alpha_add_israndom, ptype_edit.alpha_add_random_min * 100, ptype_edit.alpha_add_random_max * 100, 
	1 / 2, -no_limit, no_limit, array(0, -10, -5), 0, 
	array(tab.tbx_type_alpha_add, tab.tbx_type_alpha_add_random), 
	array(action_lib_pc_type_alpha_add, action_lib_pc_type_alpha_add_israndom, action_lib_pc_type_alpha_add_random_min, action_lib_pc_type_alpha_add_random_max))
	
// Color
tab_control_color()
draw_checkbox("particleeditorrandom", dx + dw - 75, dy + 6, ptype_edit.color_israndom, action_lib_pc_type_color_israndom)
if (ptype_edit.color_israndom)
{
	draw_button_color("particleeditortypecolorrandomstart", dx, dy, (dw - 85) / 2-4, ptype_edit.color_random_start, c_gray, false, action_lib_pc_type_color_random_start)
	draw_button_color("particleeditortypecolorrandomend", dx + floor((dw - 85) / 2+4), dy, floor((dw - 85) / 2-4), ptype_edit.color_random_end, c_white, false, action_lib_pc_type_color_random_end)
}
else
	draw_button_color("particleeditortypecolorcolor", dx, dy, dw - 85, ptype_edit.color, c_white, false, action_lib_pc_type_color)
tab_next()

// Color mix
tab_control_checkbox()
draw_checkbox("particleeditortypecolormixenabled", dx, dy, ptype_edit.color_mix_enabled, action_lib_pc_type_color_mix_enabled)
tab_next()
if (ptype_edit.color_mix_enabled)
{
	tab_control_color()
	draw_checkbox("particleeditorrandom", dx + dw - 75, dy + 6, ptype_edit.color_mix_israndom, action_lib_pc_type_color_mix_israndom)
	if (ptype_edit.color_mix_israndom)
	{
		draw_button_color("particleeditortypecolormixrandomstart", dx, dy, (dw - 85) / 2-4, ptype_edit.color_mix_random_start, c_gray, false, action_lib_pc_type_color_mix_random_start)
		draw_button_color("particleeditortypecolormixrandomend", dx + floor((dw - 85) / 2+4), dy, floor((dw - 85) / 2-4), ptype_edit.color_mix_random_end, c_white, false, action_lib_pc_type_color_mix_random_end)
	}
	else
		draw_button_color("particleeditortypecolormix", dx, dy, dw - 85, ptype_edit.color_mix, c_black, false, action_lib_pc_type_color_mix)
	tab_next()
	
	tab.tbx_type_color_mix_time.suffix = test(ptype_edit.color_mix_time_israndom, "", " " + text_get("particleeditorseconds"))
	tab.tbx_type_color_mix_time_random.suffix = " " + text_get("particleeditorseconds")
	tab_template_editor_particles_value("particleeditortypecolormixtime", 
		ptype_edit.color_mix_time, ptype_edit.color_mix_time_israndom, ptype_edit.color_mix_time_random_min, ptype_edit.color_mix_time_random_max, 
		1 / 20, 0, no_limit, array(3, 1, 5), 0, 
		array(tab.tbx_type_color_mix_time, tab.tbx_type_color_mix_time_random), 
		array(action_lib_pc_type_color_mix_time, action_lib_pc_type_color_mix_time_israndom, action_lib_pc_type_color_mix_time_random_min, action_lib_pc_type_color_mix_time_random_max))
}
dy += 10

// Spawn region / Bounding box
tab_control_checkbox()
draw_checkbox("particleeditortypespawnregion", dx, dy, ptype_edit.spawn_region, action_lib_pc_type_spawn_region)
draw_checkbox("particleeditortypeboundingbox", dx + floor(dw * 0.5), dy, ptype_edit.bounding_box, action_lib_pc_type_bounding_box)
tab_next()
if (ptype_edit.bounding_box)
{
	// Bounce
	tab_control_dragger()
	draw_checkbox("particleeditortypebounce", dx, dy + 1, ptype_edit.bounce, action_lib_pc_type_bounce)
	if (ptype_edit.bounce)
		draw_dragger("particleeditortypebouncefactor", dx + floor(dw * 0.3), dy, dw * 0.7, ptype_edit.bounce_factor, 1 / 100, 0, no_limit, 0.5, 0, tab.tbx_type_bounce_factor, action_lib_pc_type_bounce_factor)
	tab_next()
}

// Orbit attractor
tab_control_checkbox()
draw_checkbox("particleeditortypeorbit", dx, dy, ptype_edit.orbit, action_lib_pc_type_orbit)
tab_next()
