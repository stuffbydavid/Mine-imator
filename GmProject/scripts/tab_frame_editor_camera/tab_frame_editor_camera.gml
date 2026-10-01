function tab_frame_editor_camera()
{
	// FOV
	tab_control_dragger()
	draw_dragger("frameeditorcamerafov", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FOV], 1, 1, 170, 45, 0, tab.camera.tbx_fov, action_tl_frame_cam_fov)
	tab_next()
	
	// Camera size (Advanced mode only)
	if (setting_advanced_mode)
	{
		if (tl_edit.value[e_value.CAM_SIZE_USE_PROJECT]) // Use project settings
		{
			tab.camera.video_template = null
			content_text = text_get("frameeditorcameravideosizeuseproject")
		}
		else
		{
			if (tab.camera.video_template = null)
				tab.camera.video_template = find_videotemplate(tl_edit.value[e_value.CAM_WIDTH], tl_edit.value[e_value.CAM_HEIGHT])
			
			if (tab.camera.video_template > 0) // Use template
				content_text = text_get("projectvideosizetemplate" + tab.camera.video_template.name) + " (" + string(tab.camera.video_template.width) + "x" + string(tab.camera.video_template.height) + ")"
			else // Use custom
				content_text = text_get("projectvideosizecustom")
		}
		
		tab_control_menu()
		draw_button_menu("frameeditorcameravideosize", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.CAM_SIZE_USE_PROJECT] ? null : tab.camera.video_template, content_text, action_tl_frame_cam_video_template)
		tab_next()
		
		// Custom
		if (tab.camera.video_template = 0)
		{
			textfield_group_add("frameeditorcameravideosizecustomwidth", tl_edit.value[e_value.CAM_WIDTH], 1280, action_tl_frame_cam_width, X, tab.camera.tbx_video_size_custom_width, null, 1)
			textfield_group_add("frameeditorcameravideosizecustomheight", tl_edit.value[e_value.CAM_HEIGHT], 720, action_tl_frame_cam_height, X, tab.camera.tbx_video_size_custom_height, null, 1)
			
			tab_control_textfield_group()
			draw_textfield_group("frameeditorcameravideosizecustom", dx, dy, dw, 1, 1, no_limit, 1)
			tab_next()
			
			tab_control_switch()
			draw_switch("frameeditorcameravideosizecustomkeepaspectratio", dx, dy, tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO], action_tl_frame_cam_size_keep_aspect_ratio)
			tab_next()
			
			dy += 8
		}
	}
	
	// Rotate around point
	tab_control_switch()
	draw_button_collapse("rotatepoint", collapse_map[?"rotatepoint"], action_tl_frame_cam_rotate, tl_edit.value[e_value.CAM_ROTATE], "frameeditorcamerarotate")
	tab_next()

	if (tl_edit.value[e_value.CAM_ROTATE] && collapse_map[?"rotatepoint"])
	{
		tab_collapse_start()
		
		// XY / Z angle wheels
		var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);
		
		tab_control_wheel()
		axis_edit = setting_z_is_up ? Y : Z
		draw_wheel("frameeditorcamerarotateanglexywheel", dx + floor(dw * 0.25), dy + 24, c_control_yellow, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], -no_limit, no_limit, 0, snapval, tab.camera.tbx_rotate_angle_xy, action_tl_frame_cam_rotate_angle_xy)
		axis_edit = X
		draw_wheel("frameeditorcamerarotateanglezwheel", dx + floor(dw * 0.75), dy + 24, c_control_cyan, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], -no_limit, no_limit, 0, snapval, tab.camera.tbx_rotate_angle_z, action_tl_frame_cam_rotate_angle_z)
		tab_next()
		
		// Textboxes
		axis_edit = setting_z_is_up ? Y : Z
		textfield_group_add(setting_z_is_up ? "frameeditorcamerarotateanglexy" : "frameeditorcamerarotateanglexz", tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], 0, action_tl_frame_cam_rotate_angle_xy, axis_edit, tab.camera.tbx_rotate_angle_xy, null, .1, -no_limit, no_limit)
		axis_edit = X
		textfield_group_add(setting_z_is_up ? "frameeditorcamerarotateanglez" : "frameeditorcamerarotateangley", tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], 0, action_tl_frame_cam_rotate_angle_z, axis_edit, tab.camera.tbx_rotate_angle_z, null, .1, -no_limit, no_limit)
		
		tab_control_textfield_group()
		draw_textfield_group("frameeditorcamerarotateangle", dx, dy, dw, 0.1, 0, 0, snapval, false, true, 2)
		tab_next()
		
		// Distance
		tab_control_dragger()
		draw_dragger("frameeditorcamerarotatedistance", dx, dy, dragger_width, tl_edit.value[e_value.CAM_ROTATE_DISTANCE], 1, 1, no_limit, 100, 0, tab.camera.tbx_rotate_distance, action_tl_frame_cam_rotate_distance)
		tab_next()
		
		// Look at
		tab_control_switch()
		draw_switch("frameeditorcamerarotatelookatpoint", dx, dy, tab.camera.look_at_rotate, action_tl_frame_look_at_rotate)
		tab_next()
		
		tab_collapse_end()
	}
}