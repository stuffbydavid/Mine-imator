/// tab_frame_editor_camera()

var capwid, text;
capwid = text_caption_width("frameeditorcamerafov", "frameeditorcameravideosize", "projectvideosizecustomwidth");

// FOV
tab_control_meter()
draw_meter("frameeditorcamerafov", dx, dy, dw, tl_edit.value[e_value.CAM_FOV], 50, 1, 170, 45, 1, tab.camera.tbx_fov, action_tl_frame_cam_fov, capwid)
tab_next()

// Rotate point 
tab_control_checkbox()
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
}

// DOF
tab_control_checkbox()
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
	
	tab_control(24)
	capwid = text_caption_width("frameeditorcameradofforeground")
	
	if (draw_button_normal("frameeditorcameradofforeground", dx, dy, capwid, 24))
		action_tl_frame_cam_dof_foreground()
		
	if (draw_button_normal("frameeditorcameradofbackground", dx + capwid + 8, dy, text_caption_width("frameeditorcameradofbackground"), 24))
		action_tl_frame_cam_dof_background()
		
	tab_next()
	
	dx -= 4
	dw += 4
}

// Bloom
tab_control_checkbox()
draw_checkbox_expand("frameeditorcamerabloom", dx, dy, tl_edit.value[e_value.CAM_BLOOM], action_tl_frame_cam_bloom, checkbox_expand_frameeditor_bloom, action_checkbox_expand_frameeditor_bloom)
tab_next()
if (tl_edit.value[e_value.CAM_BLOOM] && checkbox_expand_frameeditor_bloom)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcamerabloomthreshold", "frameeditorcamerabloomintensity", "frameeditorcamerabloomradius")
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomthreshold", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_THRESHOLD] * 100), 50, 0, 100, 85, 1, tab.camera.tbx_bloom_threshold, action_tl_frame_cam_bloom_threshold, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomradius", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_RADIUS] * 100), 50, 0, 300, 100, 1, tab.camera.tbx_bloom_radius, action_tl_frame_cam_bloom_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcamerabloomintensity", dx, dy, dw, round(tl_edit.value[e_value.CAM_BLOOM_INTENSITY] * 100), 50, 0, 300, 40, 1, tab.camera.tbx_bloom_intensity, action_tl_frame_cam_bloom_intensity, capwid)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorcamerabloomblend", dx, dy, dw, tl_edit.value[e_value.CAM_BLOOM_BLEND], c_white, false, action_tl_frame_cam_bloom_blend)
	tab_next()
	
	dx -= 4
	dw += 4
}

// Color correction
tab_control_checkbox()
draw_checkbox_expand("frameeditorcameracolorcorrection", dx, dy, tl_edit.value[e_value.CAM_COLOR_CORRECTION], action_tl_frame_cam_clrcor, checkbox_expand_frameeditor_clrcor, action_checkbox_expand_frameeditor_clrcor)
tab_next()
if (tl_edit.value[e_value.CAM_COLOR_CORRECTION] && checkbox_expand_frameeditor_clrcor)
{
	dx += 4
	dw -= 4
	
	capwid = text_caption_width("frameeditorcameracolorcorrectioncontrast", "frameeditorcameracolorcorrectionbrightness", "frameeditorcameracolorcorrectionsaturation")
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectioncontrast", dx, dy, dw, round(tl_edit.value[e_value.CAM_CONTRAST] * 100), 50, 0, 100, 20, 1, tab.camera.tbx_contrast, action_tl_frame_cam_clrcor_contrast, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectionbrightness", dx, dy, dw, round(tl_edit.value[e_value.CAM_BRIGHTNESS] * 100), 50, 0, 100, 0, 1, tab.camera.tbx_brightness, action_tl_frame_cam_clrcor_brightness, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorcameracolorcorrectionsaturation", dx, dy, dw, round(tl_edit.value[e_value.CAM_SATURATION] * 100), 50, 0, 200, 100, 1, tab.camera.tbx_saturation, action_tl_frame_cam_clrcor_saturation, capwid)
	tab_next()
	
	dx -= 4
	dw += 4
}

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
