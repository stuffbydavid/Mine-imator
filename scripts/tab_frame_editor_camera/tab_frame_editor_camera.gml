/// tab_frame_editor_camera()

var capwid, text;
capwid = text_caption_width("frameeditorcamerafov", "frameeditorcameravideosize", "projectvideosizecustomwidth");

// FOV
tab_control_meter()
draw_meter("frameeditorcamerafov", dx, dy, dw, tl_edit.value[CAMFOV], 50, 1, 170, 45, 1, tab.camera.tbx_fov, action_tl_frame_camfov, capwid)
tab_next()

// Rotate point 
tab_control_checkbox()
draw_checkbox("frameeditorcamerarotate", dx, dy, tl_edit.value[CAMROTATE], action_tl_frame_camrotate)
tab_next()

if (tl_edit.value[CAMROTATE])
{
	// Distance
	tab_control_dragger()
	draw_dragger("frameeditorcamerarotatedistance", dx, dy, dw, tl_edit.value[CAMROTATEDISTANCE], 1, 1, no_limit, 100, 0, tab.camera.tbx_rotate_distance, action_tl_frame_camrotatedistance)
	tab_next()
	
	// XY / Z angle
	tab_control(13)
	draw_label(text_get("frameeditorcamerarotateangle") + ":", dx, dy)
	tab_next()
	
	tab_control(100)
	draw_wheel("frameeditorcamerarotatexyangle", dx + floor(dw * 0.3), dy + 50, c_aqua, tl_edit.value[CAMROTATEXYANGLE], -no_limit, no_limit, 0, 0, false, tab.camera.tbx_rotate_angle_xy, action_tl_frame_camrotatexyangle)
	draw_wheel("frameeditorcamerarotatezangle", dx + floor(dw * 0.7), dy + 50, c_aqua, tl_edit.value[CAMROTATEZANGLE], -89.9, 89.9, 0, 0, false, tab.camera.tbx_rotate_angle_z, action_tl_frame_camrotatezangle)
	tab_next()
	
	// Look at
	tab_control_checkbox()
	draw_checkbox("frameeditorcameralookatrotate", dx, dy, tab.camera.look_at_rotate, action_tl_frame_look_at_rotate)
	tab_next()
}

// DOF
tab_control_checkbox()
draw_checkbox("frameeditorcameradof", dx, dy, tl_edit.value[CAMDOF], action_tl_frame_camdof)
tab_next()
if (tl_edit.value[CAMDOF])
{
	capwid = text_caption_width("frameeditorcameradofdepth", "frameeditorcameradofrange", "frameeditorcameradoffadesize")
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofdepth", dx, dy, dw, tl_edit.value[CAMDOFDEPTH], max(0.5, tl_edit.value[CAMDOFDEPTH] / 50), 0, world_size, 0, 0, tab.camera.tbx_dof_depth, action_tl_frame_camdofdepth)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofrange", dx, dy, dw, tl_edit.value[CAMDOFRANGE], max(0.5, tl_edit.value[CAMDOFRANGE] / 50), 0, no_limit, 200, 0, tab.camera.tbx_dof_range, action_tl_frame_camdofrange)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradoffadesize", dx, dy, dw, tl_edit.value[CAMDOFFADESIZE], 2, 0, no_limit, 100, 0, tab.camera.tbx_dof_fade_size, action_tl_frame_camdoffadesize)
	tab_next()
	
	tab_control(24)
	capwid = text_caption_width("frameeditorcameradofforeground")
	
	if (draw_button_normal("frameeditorcameradofforeground", dx, dy, capwid, 24))
		action_tl_frame_camdof_foreground()
		
	if (draw_button_normal("frameeditorcameradofbackground", dx + capwid + 8, dy, text_caption_width("frameeditorcameradofbackground"), 24))
		action_tl_frame_camdof_background()
		
	tab_next()
}

// Camera size
if (tl_edit.value[CAMSIZEUSEPROJECT]) // Use project settings
{
	tab.camera.video_template = null
	text = text_get("frameeditorcameravideosizeuseproject")
}
else
{
	if (tab.camera.video_template = null)
		tab.camera.video_template = find_videotemplate(tl_edit.value[CAMWIDTH], tl_edit.value[CAMHEIGHT])
		
	if (tab.camera.video_template > 0) // Use template
		text = tab.camera.video_template.name + " (" + string(tab.camera.video_template.width) + "x" + string(tab.camera.video_template.height) + ")"
	else // Use custom
		text = text_get("projectvideosizecustom")
}

tab_control(24)
draw_button_menu("frameeditorcameravideosize", e_menu.LIST, dx, dy, dw, 24, test(tl_edit.value[CAMSIZEUSEPROJECT], null, tab.camera.video_template), text, action_tl_frame_cam_video_template, null, 0, capwid)
tab_next()

// Custom
if (tab.camera.video_template = 0)
{
	tab_control_dragger()
	draw_dragger("frameeditorcameravideosizecustomwidth", dx, dy, 140, tl_edit.value[CAMWIDTH], 1, 1, no_limit, 1280, 1, tab.camera.tbx_video_size_custom_width, action_tl_frame_camwidth, capwid)
	draw_dragger("frameeditorcameravideosizecustomheight", dx + 140, dy, dw - 140, tl_edit.value[CAMHEIGHT], 1, 1, no_limit, 720, 1, tab.camera.tbx_video_size_custom_height, action_tl_frame_camheight)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("frameeditorcameravideosizecustomkeepaspectratio", dx, dy, tl_edit.value[CAMSIZEKEEPASPECTRATIO], action_tl_frame_camsizekeepaspectratio)
	tab_next()
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorcamerareset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_tl_frame_set_camera(45, tl_edit.value[CAMROTATE], 100, 0, 0, tl_edit.value[CAMDOF], 0, 200, 100, null, null)
	
if (draw_button_normal("frameeditorcameracopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
{
	tab.camera.copy_fov = tl_edit.value[CAMFOV]
	tab.camera.copy_rotate = tl_edit.value[CAMROTATE]
	tab.camera.copy_rotate_distance = tl_edit.value[CAMROTATEDISTANCE]
	tab.camera.copy_rotate_xy_angle = tl_edit.value[CAMROTATEXYANGLE]
	tab.camera.copy_rotate_z_angle = tl_edit.value[CAMROTATEZANGLE]
	tab.camera.copy_dof = tl_edit.value[CAMDOF]
	tab.camera.copy_dof_depth = tl_edit.value[CAMDOFDEPTH]
	tab.camera.copy_dof_range = tl_edit.value[CAMDOFRANGE]
	tab.camera.copy_dof_fade_size = tl_edit.value[CAMDOFFADESIZE]
	tab.camera.copy_width = tl_edit.value[CAMWIDTH]
	tab.camera.copy_height = tl_edit.value[CAMHEIGHT]
}

if (draw_button_normal("frameeditorcamerapaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
{
	action_tl_frame_set_camera(tab.camera.copy_fov, 
							   tab.camera.copy_rotate, 
							   tab.camera.copy_rotate_distance, 
							   tab.camera.copy_rotate_xy_angle, 
							   tab.camera.copy_rotate_z_angle, 
							   tab.camera.copy_dof, 
							   tab.camera.copy_dof_depth, 
							   tab.camera.copy_dof_range, 
							   tab.camera.copy_dof_fade_size, 
							   tab.camera.copy_width, 
							   tab.camera.copy_height)
}

tab_next()
