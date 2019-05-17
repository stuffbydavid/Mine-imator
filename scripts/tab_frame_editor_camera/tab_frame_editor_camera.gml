/// tab_frame_editor_camera()

var capwid, text;
capwid = text_caption_width("frameeditorcamerafov");

// FOV
tab_control_meter()
draw_meter("frameeditorcamerafov", dx, dy, dw, tl_edit.value[e_value.CAM_FOV], 50, 1, 170, 45, 1, tab.camera.tbx_fov, action_tl_frame_cam_fov, capwid)
tab_next()

// Rotate point
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcamerarotate", dx, dy, tl_edit.value[e_value.CAM_ROTATE], action_tl_frame_cam_rotate, checkbox_expand_frameeditor_rotatepoint, action_checkbox_expand_frameeditor_rotatepoint)
tab_next()

if (tl_edit.value[e_value.CAM_ROTATE] && checkbox_expand_frameeditor_rotatepoint)
{
	dx += 4
	dw -= 4
	
	// Distance
	tab_control_dragger()
	draw_dragger("frameeditorcamerarotatedistance", dx, dy, dw, tl_edit.value[e_value.CAM_ROTATE_DISTANCE], 1, 1, no_limit, 100, 0, tab.camera.tbx_rotate_distance, action_tl_frame_cam_rotate_distance)
	tab_next()
	
	// XY / Z angle
	tab_control(13)
	draw_label(text_get("frameeditorcamerarotateangle") + ":", dx, dy)
	tab_next()
	
	tab_control(100)
	draw_wheel("frameeditorcamerarotateanglexy", dx + floor(dw * 0.3), dy + 50, c_aqua, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], -no_limit, no_limit, 0, 0, false, tab.camera.tbx_rotate_angle_xy, action_tl_frame_cam_rotate_angle_xy)
	draw_wheel("frameeditorcamerarotateanglez", dx + floor(dw * 0.7), dy + 50, c_aqua, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], -89.9, 89.9, 0, 0, false, tab.camera.tbx_rotate_angle_z, action_tl_frame_cam_rotate_angle_z)
	tab_next()
	
	// Look at
	tab_control_checkbox()
	draw_checkbox("frameeditorcameralookatrotate", dx, dy, tab.camera.look_at_rotate, action_tl_frame_look_at_rotate)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Camera shake
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameracamerashake", dx, dy, tl_edit.value[e_value.CAM_SHAKE], action_tl_frame_cam_shake, checkbox_expand_frameeditor_camshake, action_checkbox_expand_frameeditor_camshake)
tab_next()
if (tl_edit.value[e_value.CAM_SHAKE] && checkbox_expand_frameeditor_camshake)
{
	dx += 4
	dw -= 4
	
	// Shake strength
	tab_control_meter()
	draw_meter("frameeditorcameracamerashakestrength", dx, dy, dw, round(tl_edit.value[e_value.CAM_SHAKE_STRENGTH] * 100), 48, 0, 800, 25, 1, tab.camera.tbx_shake_strength, action_tl_frame_cam_shake_strength)
	tab_next()
	
	capwid = text_caption_width("frameeditorcameracamerashakehoffset", "frameeditorcameracamerashakehspeed", "frameeditorcameracamerashakehstrength",
								"frameeditorcameracamerashakevoffset", "frameeditorcameracamerashakevspeed", "frameeditorcameracamerashakevstrength")
	
	// Vertical offset
	tab_control_dragger()
	draw_dragger("frameeditorcameracamerashakevoffset", dx, dy, dw, tl_edit.value[e_value.CAM_SHAKE_VERTICAL_OFFSET], 1, -no_limit, no_limit, 0, 0, tab.camera.tbx_shake_voffset, action_tl_frame_cam_shake_voffset, capwid)
	tab_next()
	
	// Horizontal offset
	tab_control_dragger()
	draw_dragger("frameeditorcameracamerashakehoffset", dx, dy, dw, tl_edit.value[e_value.CAM_SHAKE_HORIZONTAL_OFFSET], 1, -no_limit, no_limit, 0, 0, tab.camera.tbx_shake_hoffset, action_tl_frame_cam_shake_hoffset, capwid)
	tab_next()
	
	// Vertical speed
	tab_control_meter()
	draw_meter("frameeditorcameracamerashakevspeed", dx, dy, dw, round(tl_edit.value[e_value.CAM_SHAKE_VERTICAL_SPEED] * 100), 48, 0, 500, 100, 1, tab.camera.tbx_shake_vspeed, action_tl_frame_cam_shake_vspeed, capwid)
	tab_next()
	
	// Horizontal speed
	tab_control_meter()
	draw_meter("frameeditorcameracamerashakehspeed", dx, dy, dw, round(tl_edit.value[e_value.CAM_SHAKE_HORIZONTAL_SPEED] * 100), 48, 0, 500, 100, 1, tab.camera.tbx_shake_hspeed, action_tl_frame_cam_shake_hspeed, capwid)
	tab_next()
	
	// Vertical strength
	tab_control_meter()
	draw_meter("frameeditorcameracamerashakevstrength", dx, dy, dw, round(tl_edit.value[e_value.CAM_SHAKE_VERTICAL_STRENGTH] * 100), 48, 0, 800, 100, 1, tab.camera.tbx_shake_vstrength, action_tl_frame_cam_shake_vstrength, capwid)
	tab_next()
	
	// Horizontal strength
	tab_control_meter()
	draw_meter("frameeditorcameracamerashakehstrength", dx, dy, dw, round(tl_edit.value[e_value.CAM_SHAKE_HORIZONTAL_STRENGTH] * 100), 48, 0, 800, 100, 1, tab.camera.tbx_shake_hstrength, action_tl_frame_cam_shake_hstrength, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// DOF
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameradof", dx, dy, tl_edit.value[e_value.CAM_DOF], action_tl_frame_cam_dof, checkbox_expand_frameeditor_dof, action_checkbox_expand_frameeditor_dof)
tab_next()
if (tl_edit.value[e_value.CAM_DOF] && checkbox_expand_frameeditor_dof)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcameradofdepth", "frameeditorcameradofrange", "frameeditorcameradoffadesize", "frameeditorcameradofblursize")
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofdepth", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_DEPTH], max(0.5, tl_edit.value[e_value.CAM_DOF_DEPTH] / 50), 0, world_size, 0, 0, tab.camera.tbx_dof_depth, action_tl_frame_cam_dof_depth)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofrange", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_RANGE], max(0.5, tl_edit.value[e_value.CAM_DOF_RANGE] / 50), 0, no_limit, 200, 0, tab.camera.tbx_dof_range, action_tl_frame_cam_dof_range)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradoffadesize", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_FADE_SIZE], 2, 0, no_limit, 100, 0, tab.camera.tbx_dof_fade_size, action_tl_frame_cam_dof_fade_size)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameradofblursize", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_BLUR_SIZE] * 100, 48, 0, 10, 1, 0, tab.camera.tbx_dof_blur_size, action_tl_frame_cam_dof_blur_size)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameradofblurratio", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_BLUR_RATIO] * 100), 48, -100, 100, 0, 1, tab.camera.tbx_dof_blur_ratio, action_tl_frame_cam_dof_blur_ratio)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameradofbias", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_BIAS] * 10), 48, 0, 100, 0, 1, tab.camera.tbx_dof_bias, action_tl_frame_cam_dof_bias)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameradofgain", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_GAIN] * 100), 48, 0, 200, 0, 1, tab.camera.tbx_dof_gain, action_tl_frame_cam_dof_gain)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameradofthreshold", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_THRESHOLD] * 100), 48, 0, 100, 0, 1, tab.camera.tbx_dof_threshold, action_tl_frame_cam_dof_threshold)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("frameeditorcameradoffringe", dx, dy, tl_edit.value[e_value.CAM_DOF_FRINGE], action_tl_frame_cam_dof_fringe)
	tab_next()
	
	if (tl_edit.value[e_value.CAM_DOF_FRINGE])
	{
		var snapval, capwid;
		snapval = tab.camera.snap_fringe_enabled * tab.camera.snap_fringe_size
	
		tab_control(100)
		axis_edit = X
		draw_wheel("frameeditorcameradoffringeanglered", dx + floor(dw * 0.25) - 25, dy + 50, c_red, tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_RED], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_DOF_FRINGE_ANGLE_RED], snapval, false, tab.camera.tbx_dof_fringe_angle_red, action_tl_frame_cam_dof_fringe_angle)
	
		axis_edit = Y
		draw_wheel("frameeditorcameradoffringeanglegreen", dx + floor(dw * 0.5), dy + 50, c_green, tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_DOF_FRINGE_ANGLE_GREEN], snapval, false, tab.camera.tbx_dof_fringe_angle_green, action_tl_frame_cam_dof_fringe_angle)
	
		axis_edit = Z
		draw_wheel("frameeditorcameradoffringeangleblue", dx + floor(dw * 0.75) + 25, dy + 50, c_blue, tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_DOF_FRINGE_ANGLE_BLUE], snapval, false, tab.camera.tbx_dof_fringe_angle_blue, action_tl_frame_cam_dof_fringe_angle)
		tab_next()
		
		// Angle snap
		tab_control(24)
		
		if (draw_button_normal("frameeditorcameradoffringesnap", dx, dy, 24, 24, e_button.NO_TEXT, tab.camera.snap_fringe_enabled, false, true, icons.GRID))
			tab.camera.snap_fringe_enabled = !tab.camera.snap_fringe_enabled
		
		if (tab.camera.snap_fringe_enabled)
		{
			capwid = text_caption_width("frameeditorcameradoffringesnapsize")
			if (draw_inputbox("frameeditorcameradoffringesnapsize", dx + dw - capwid - 50, dy + 4, capwid + 50, "", tab.camera.tbx_snap_fringe, null))
				tab.camera.snap_fringe_size = string_get_real(tab.camera.tbx_snap_fringe.text, 0)
		}
		tab_next()
		
		capwid = text_caption_width("frameeditorcameradoffringered", "frameeditorcameradoffringegreen", "frameeditorcameradoffringeblue")
		
		tab_control_meter()
		draw_meter("frameeditorcameradoffringered", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_FRINGE_RED] * 100), 48, 0, 300, 100, 1, tab.camera.tbx_dof_fringe_red, action_tl_frame_cam_dof_fringe_red, capwid)
		tab_next()
	
		tab_control_meter()
		draw_meter("frameeditorcameradoffringegreen", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_FRINGE_GREEN] * 100), 48, 0, 300, 100, 1, tab.camera.tbx_dof_fringe_green, action_tl_frame_cam_dof_fringe_green, capwid)
		tab_next()
	
		tab_control_meter()
		draw_meter("frameeditorcameradoffringeblue", dx, dy, dw, round(tl_edit.value[e_value.CAM_DOF_FRINGE_BLUE] * 100), 48, 0, 300, 100, 1, tab.camera.tbx_dof_fringe_blue, action_tl_frame_cam_dof_fringe_blue, capwid)
		tab_next()
		
		// Tools
		tab_control(24)
		
		if (draw_button_normal("frameeditorcameradoffringereset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
			action_tl_frame_cam_dof_fringe_all(array(tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_RED], tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN], tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE], tl_edit.value[e_value.CAM_DOF_FRINGE_RED], tl_edit.value[e_value.CAM_DOF_FRINGE_GREEN], tl_edit.value[e_value.CAM_DOF_FRINGE_BLUE]))
		
		if (draw_button_normal("frameeditorcameradoffringecopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
			tab.camera.fringe_copy = array(tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_RED], tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN], tl_edit.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE],
										   tl_edit.value[e_value.CAM_DOF_FRINGE_RED], tl_edit.value[e_value.CAM_DOF_FRINGE_GREEN], tl_edit.value[e_value.CAM_DOF_FRINGE_BLUE])
		
		if (draw_button_normal("frameeditorcameradoffringepaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
			action_tl_frame_cam_dof_fringe_all(tab.camera.fringe_copy)
		
		tab_next()
	}
	
	tab_control(24)
	capwid = text_caption_width("frameeditorcameradofforeground")
	
	if (draw_button_normal("frameeditorcameradofforeground", dx, dy, capwid, 24))
		action_tl_frame_cam_dof_foreground()
		
	if (draw_button_normal("frameeditorcameradofbackground", dx + capwid + 8, dy, text_caption_width("frameeditorcameradofbackground"), 24))
		action_tl_frame_cam_dof_background()
		
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Bloom
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcamerabloom", dx, dy, tl_edit.value[e_value.CAM_BLOOM], action_tl_frame_cam_bloom, checkbox_expand_frameeditor_bloom, action_checkbox_expand_frameeditor_bloom)
tab_next()
if (tl_edit.value[e_value.CAM_BLOOM] && checkbox_expand_frameeditor_bloom)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcamerabloomthreshold", "frameeditorcamerabloomintensity", "frameeditorcamerabloomradius", "frameeditorcamerabloomratio")
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomthreshold", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_THRESHOLD] * 100), 50, 0, 100, 85, 1, tab.camera.tbx_bloom_threshold, action_tl_frame_cam_bloom_threshold, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomradius", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_RADIUS] * 100), 50, 0, 300, 100, 1, tab.camera.tbx_bloom_radius, action_tl_frame_cam_bloom_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomintensity", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_INTENSITY] * 100), 50, 0, 300, 40, 1, tab.camera.tbx_bloom_intensity, action_tl_frame_cam_bloom_intensity, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomratio", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_RATIO] * 100), 50, -100, 100, 0, 1, tab.camera.tbx_bloom_ratio, action_tl_frame_cam_bloom_ratio, capwid)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorcamerabloomblend", dx, dy, dw, tl_edit.value[e_value.CAM_BLOOM_BLEND], c_white, false, action_tl_frame_cam_bloom_blend)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Lens dirt
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameralensdirt", dx, dy, tl_edit.value[e_value.CAM_LENS_DIRT], action_tl_frame_cam_lens_dirt, checkbox_expand_frameeditor_lensdirt, action_checkbox_expand_frameeditor_lensdirt)
tab_next()
if (tl_edit.value[e_value.CAM_LENS_DIRT] && checkbox_expand_frameeditor_lensdirt)
{
	dx += 4
	dw -= 4
	
	// Lens dirt texture(TEXTURE_OBJ)
	var texobj, tex;
	texobj = tl_edit.value[e_value.TEXTURE_OBJ]
	tex = null



	var text;
	
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")

	if (texobj = null)
		text = text_get("listdefault", text)
	
	if (texobj != null && texobj.type != e_tl_type.CAMERA) // Don't preview cameras
		tex = texobj.texture
	
	tab_control(40)
	draw_button_menu("frameeditorcameralensdirttexture", e_menu.LIST, dx, dy, dw, 40, tl_edit.value[e_value.TEXTURE_OBJ], text, action_tl_frame_texture_obj, tex)
	tab_next()
	
	// Affected by bloom
	tab_control_checkbox()
	draw_checkbox("frameeditorcameralensdirtbloom", dx, dy, tl_edit.value[e_value.CAM_LENS_DIRT_BLOOM], action_tl_frame_cam_lens_dirt_bloom)
	tab_next()
	
	// Affected by glow
	tab_control_checkbox()
	draw_checkbox("frameeditorcameralensdirtglow", dx, dy, tl_edit.value[e_value.CAM_LENS_DIRT_GLOW], action_tl_frame_cam_lens_dirt_glow)
	tab_next()
	
	// Radius
	tab_control_meter()
	draw_meter("frameeditorcameralensdirtradius", dx, dy, dw, round(tl_edit.value[e_value.CAM_LENS_DIRT_RADIUS] * 100), 50, 0, 300, 50, 1, tab.camera.tbx_lens_dirt_radius, action_tl_frame_cam_lens_dirt_radius, capwid)
	tab_next()
	
	// Intensity
	tab_control_meter()
	draw_meter("frameeditorcameralensdirtintensity", dx, dy, dw, round(tl_edit.value[e_value.CAM_LENS_DIRT_INTENSITY] * 100), 50, 0, 200, 80, 1, tab.camera.tbx_lens_dirt_intensity, action_tl_frame_cam_lens_dirt_intensity, capwid)
	tab_next()
	
	// Power
	tab_control_meter()
	draw_meter("frameeditorcameralensdirtpower", dx, dy, dw, round(tl_edit.value[e_value.CAM_LENS_DIRT_POWER] * 100), 50, 100, 500, 150, 1, tab.camera.tbx_lens_dirt_power, action_tl_frame_cam_lens_dirt_power, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Color correction
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameracolorcorrection", dx, dy, tl_edit.value[e_value.CAM_COLOR_CORRECTION], action_tl_frame_cam_clrcor, checkbox_expand_frameeditor_clrcor, action_checkbox_expand_frameeditor_clrcor)
tab_next()
if (tl_edit.value[e_value.CAM_COLOR_CORRECTION] && checkbox_expand_frameeditor_clrcor)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcameracolorcorrectioncontrast", "frameeditorcameracolorcorrectionbrightness", "frameeditorcameracolorcorrectionsaturation")
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectioncontrast", dx, dy, dw, round(tl_edit.value[e_value.CAM_CONTRAST] * 100), 50, 0, 100, 0, 1, tab.camera.tbx_contrast, action_tl_frame_cam_clrcor_contrast, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectionbrightness", dx, dy, dw, round(tl_edit.value[e_value.CAM_BRIGHTNESS] * 100), 50, -100, 100, 0, 1, tab.camera.tbx_brightness, action_tl_frame_cam_clrcor_brightness, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectionsaturation", dx, dy, dw, round(tl_edit.value[e_value.CAM_SATURATION] * 100), 50, 0, 200, 100, 1, tab.camera.tbx_saturation, action_tl_frame_cam_clrcor_saturation, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectionvibrance", dx, dy, dw, round(tl_edit.value[e_value.CAM_VIBRANCE] * 100), 50, 0, 100, 0, 1, tab.camera.tbx_vibrance, action_tl_frame_cam_clrcor_vibrance, capwid)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorcameracolorcorrectioncolorburn", dx, dy, dw, tl_edit.value[e_value.CAM_COLOR_BURN], c_white, false, action_tl_frame_cam_clrcor_color_burn)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Grain
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameragrain", dx, dy, tl_edit.value[e_value.CAM_GRAIN], action_tl_frame_cam_grain, checkbox_expand_frameeditor_grain, action_checkbox_expand_frameeditor_grain)
tab_next()
if (tl_edit.value[e_value.CAM_GRAIN] && checkbox_expand_frameeditor_grain)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcameragrainstrength", "frameeditorcameragrainsaturation" ,"frameeditorcameragrainsize")
	
	tab_control_meter()
	draw_meter("frameeditorcameragrainstrength", dx, dy, dw, round(tl_edit.value[e_value.CAM_GRAIN_STRENGTH] * 100), 50, -100, 100, 10, 1, tab.camera.tbx_grain_strength, action_tl_frame_cam_grain_strength, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameragrainsaturation", dx, dy, dw, round(tl_edit.value[e_value.CAM_GRAIN_SATURATION] * 100), 50, 0, 100, 10, 1, tab.camera.tbx_grain_saturation, action_tl_frame_cam_grain_saturation, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameragrainsize", dx, dy, dw, tl_edit.value[e_value.CAM_GRAIN_SIZE], 50, 1, 10, 1, 1, tab.camera.tbx_grain_size, action_tl_frame_cam_grain_size, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

// Vignette
tab_control_checkbox_expand()
draw_checkbox_expand("frameeditorcameravignette", dx, dy, tl_edit.value[e_value.CAM_VIGNETTE], action_tl_frame_cam_vignette, checkbox_expand_frameeditor_vignette, action_checkbox_expand_frameeditor_vignette)
tab_next()
if (tl_edit.value[e_value.CAM_VIGNETTE] && checkbox_expand_frameeditor_vignette)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcameravignetteradius", "frameeditorcameravignettesoftness", "frameeditorcameravignettestrength")
	
	tab_control_meter()
	draw_meter("frameeditorcameravignetteradius", dx, dy, dw, round(tl_edit.value[e_value.CAM_VIGNETTE_RADIUS] * 100), 50, 0, 100, 100, 1, tab.camera.tbx_vignette_radius, action_tl_frame_cam_vignette_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameravignettesoftness", dx, dy, dw, round(tl_edit.value[e_value.CAM_VIGNETTE_SOFTNESS] * 100), 50, 0, 100, 50, 1, tab.camera.tbx_vignette_softness, action_tl_frame_cam_vignette_softness, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameravignettestrength", dx, dy, dw, round(tl_edit.value[e_value.CAM_VIGNETTE_STRENGTH] * 100), 50, 0, 100, 100, 1, tab.camera.tbx_vignette_strength, action_tl_frame_cam_vignette_strength, capwid)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorcameravignettecolor", dx, dy, dw, tl_edit.value[e_value.CAM_VIGNETTE_COLOR], c_black, false, action_tl_frame_cam_vignette_color)
	tab_next()
	
	dx -= 4
	dw += 4
	checkbox_expand_end()
}

capwid = text_caption_width("frameeditorcameravideosize", "projectvideosizecustomwidth")

// Camera size
if (tl_edit.value[e_value.CAM_SIZE_USE_PROJECT]) // Use project settings
{
	tab.camera.video_template = null
	text = text_get("frameeditorcameravideosizeuseproject")
}
else
{
	if (tab.camera.video_template = null)
		tab.camera.video_template = find_videotemplate(tl_edit.value[e_value.CAM_WIDTH], tl_edit.value[e_value.CAM_HEIGHT])
		
	if (tab.camera.video_template > 0) // Use template
		text = text_get("projectvideosizetemplate" + tab.camera.video_template.name) + " (" + string(tab.camera.video_template.width) + "x" + string(tab.camera.video_template.height) + ")"
	else // Use custom
		text = text_get("projectvideosizecustom")
}

tab_control(24)
draw_button_menu("frameeditorcameravideosize", e_menu.LIST, dx, dy, dw, 24, test(tl_edit.value[e_value.CAM_SIZE_USE_PROJECT], null, tab.camera.video_template), text, action_tl_frame_cam_video_template, null, null, capwid)
tab_next()

// Custom
if (tab.camera.video_template = 0)
{
	tab_control_dragger()
	draw_dragger("frameeditorcameravideosizecustomwidth", dx, dy, 140, tl_edit.value[e_value.CAM_WIDTH], 1, 1, no_limit, 1280, 1, tab.camera.tbx_video_size_custom_width, action_tl_frame_cam_width, capwid)
	draw_dragger("frameeditorcameravideosizecustomheight", dx + 140, dy, dw - 140, tl_edit.value[e_value.CAM_HEIGHT], 1, 1, no_limit, 720, 1, tab.camera.tbx_video_size_custom_height, action_tl_frame_cam_height)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("frameeditorcameravideosizecustomkeepaspectratio", dx, dy, tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO], action_tl_frame_cam_size_keep_aspect_ratio)
	tab_next()
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorcamerareset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_set_camera(camera_use_default_list, true)
	
if (draw_button_normal("frameeditorcameracopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
{
	for (var i = 0; i < ds_list_size(camera_values_list); i++)
	{
		var vid = camera_values_list[|i];
		camera_values_copy[|i] = tl_edit.value[vid]
	}
}

if (draw_button_normal("frameeditorcamerapaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
	action_tl_frame_set_camera(camera_values_copy)

tab_next()
