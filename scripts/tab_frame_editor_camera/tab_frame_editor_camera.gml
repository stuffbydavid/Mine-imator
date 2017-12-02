/// tab_frame_editor_camera()

var capwid, text;
capwid = text_caption_width("frameeditorcamerafov", "frameeditorcameravideosize", "projectvideosizecustomwidth");

// FOV
tab_control_meter()
draw_meter("frameeditorcamerafov", dx, dy, dw, tl_edit.value[e_value.CAM_FOV], 50, 1, 170, 45, 1, tab.camera.tbx_fov, action_tl_frame_cam_fov, capwid)
tab_next()

// Rotate point 
tab_control_checkbox()
draw_checkbox("frameeditorcamerarotate", dx, dy, tl_edit.value[e_value.CAM_ROTATE], action_tl_frame_cam_rotate)
tab_next()

if (tl_edit.value[e_value.CAM_ROTATE])
{
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
}

// DOF
tab_control_checkbox()
draw_checkbox("frameeditorcameradof", dx, dy, tl_edit.value[e_value.CAM_DOF], action_tl_frame_cam_dof)
tab_next()
if (tl_edit.value[e_value.CAM_DOF])
{
	capwid = text_caption_width("frameeditorcameradofdepth", "frameeditorcameradofrange", "frameeditorcameradoffadesize")
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofdepth", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_DEPTH], max(0.5, tl_edit.value[e_value.CAM_DOF_DEPTH] / 50), 0, world_size, 0, 0, tab.camera.tbx_dof_depth, action_tl_frame_cam_dof_depth)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradofrange", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_RANGE], max(0.5, tl_edit.value[e_value.CAM_DOF_RANGE] / 50), 0, no_limit, 200, 0, tab.camera.tbx_dof_range, action_tl_frame_cam_dof_range)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorcameradoffadesize", dx, dy, dw, tl_edit.value[e_value.CAM_DOF_FADE_SIZE], 2, 0, no_limit, 100, 0, tab.camera.tbx_dof_fade_size, action_tl_frame_cam_dof_fade_size)
	tab_next()
	
	tab_control(24)
	capwid = text_caption_width("frameeditorcameradofforeground")
	
	if (draw_button_normal("frameeditorcameradofforeground", dx, dy, capwid, 24))
		action_tl_frame_cam_dof_foreground()
		
	if (draw_button_normal("frameeditorcameradofbackground", dx + capwid + 8, dy, text_caption_width("frameeditorcameradofbackground"), 24))
		action_tl_frame_cam_dof_background()
		
	tab_next()
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
		text = tab.camera.video_template.name + " (" + string(tab.camera.video_template.width) + "x" + string(tab.camera.video_template.height) + ")"
	else // Use custom
		text = text_get("projectvideosizecustom")
}

tab_control(24)
draw_button_menu("frameeditorcameravideosize", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.CAM_SIZE_USE_PROJECT] ? null : tab.camera.video_template, text, action_tl_frame_cam_video_template, null, null, capwid)
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
	action_tl_frame_set_camera(45, tl_edit.value[e_value.CAM_ROTATE], 100, 0, 0, tl_edit.value[e_value.CAM_DOF], 0, 200, 100, null, null)
	
if (draw_button_normal("frameeditorcameracopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
{
	tab.camera.copy_fov = tl_edit.value[e_value.CAM_FOV]
	tab.camera.copy_rotate = tl_edit.value[e_value.CAM_ROTATE]
	tab.camera.copy_rotate_distance = tl_edit.value[e_value.CAM_ROTATE_DISTANCE]
	tab.camera.copy_rotate_angle_xy = tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY]
	tab.camera.copy_rotate_angle_z = tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z]
	tab.camera.copy_dof = tl_edit.value[e_value.CAM_DOF]
	tab.camera.copy_dof_depth = tl_edit.value[e_value.CAM_DOF_DEPTH]
	tab.camera.copy_dof_range = tl_edit.value[e_value.CAM_DOF_RANGE]
	tab.camera.copy_dof_fade_size = tl_edit.value[e_value.CAM_DOF_FADE_SIZE]
	tab.camera.copy_width = tl_edit.value[e_value.CAM_WIDTH]
	tab.camera.copy_height = tl_edit.value[e_value.CAM_HEIGHT]
}

if (draw_button_normal("frameeditorcamerapaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
{
	action_tl_frame_set_camera(tab.camera.copy_fov, 
							   tab.camera.copy_rotate, 
							   tab.camera.copy_rotate_distance, 
							   tab.camera.copy_rotate_angle_xy, 
							   tab.camera.copy_rotate_angle_z, 
							   tab.camera.copy_dof, 
							   tab.camera.copy_dof_depth, 
							   tab.camera.copy_dof_range, 
							   tab.camera.copy_dof_fade_size, 
							   tab.camera.copy_width, 
							   tab.camera.copy_height)
}

tab_next()
