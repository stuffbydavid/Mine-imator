function tab_frame_editor_camera()
{
	// FOV
	tab_control_dragger()
	draw_dragger("frame_editor/camera/fov", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FOV], 1, 1, 170, 45, 0, tab.camera.tbx_fov, action_tl_frame_cam_fov)
	tab_next()
	
	// Camera size (Advanced mode only)
	if (setting_advanced_mode)
	{
		if (tl_edit.value[e_value.CAM_SIZE_USE_PROJECT]) // Use project settings
		{
			tab.camera.video_template = null
			content_text = text_get("frame_editor/camera/video_size/use_project")
		}
		else
		{
			if (tab.camera.video_template = null)
				tab.camera.video_template = find_videotemplate(tl_edit.value[e_value.CAM_WIDTH], tl_edit.value[e_value.CAM_HEIGHT])
			
			if (tab.camera.video_template > 0) // Use template
				content_text = text_get("project/video_size_template/" + tab.camera.video_template.name) + " (" + string(tab.camera.video_template.width) + "x" + string(tab.camera.video_template.height) + ")"
			else // Use custom
				content_text = text_get("project/video_size_custom")
		}
		
		tab_control_menu()
		draw_button_menu("frame_editor/camera/video_size", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.CAM_SIZE_USE_PROJECT] ? null : tab.camera.video_template, content_text, action_tl_frame_cam_video_template)
		tab_next()
		
		// Custom
		if (tab.camera.video_template = 0)
		{
			textfield_group_add("frame_editor/camera/video_size/custom_width", tl_edit.value[e_value.CAM_WIDTH], 1280, action_tl_frame_cam_width, X, tab.camera.tbx_video_size_custom_width, null, 1)
			textfield_group_add("frame_editor/camera/video_size/custom_height", tl_edit.value[e_value.CAM_HEIGHT], 720, action_tl_frame_cam_height, X, tab.camera.tbx_video_size_custom_height, null, 1)
			
			tab_control_textfield_group()
			draw_textfield_group("frame_editor/camera/video_size/custom", dx, dy, dw, 1, 1, no_limit, 1)
			tab_next()
			
			tab_control_switch()
			draw_switch("frame_editor/camera/video_size/custom_keep_aspect_ratio", dx, dy, tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO], action_tl_frame_cam_size_keep_aspect_ratio)
			tab_next()
			
			dy += 8
		}
	}
	
	// Rotate around point
	tab_control_switch()
	draw_button_collapse("frame_editor/rotatepoint", collapse_map[?"frame_editor/rotatepoint"], action_tl_frame_cam_rotate, tl_edit.value[e_value.CAM_ROTATE], "frame_editor/camera/rotate")
	tab_next()

	if (tl_edit.value[e_value.CAM_ROTATE] && collapse_map[?"frame_editor/rotatepoint"])
	{
		tab_collapse_start()
		
		// XY / Z angle wheels
		var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);
		
		tab_control_wheel()
		axis_edit = setting_z_is_up ? Y : Z
		draw_wheel("frame_editor/camera/rotate/anglexywheel", dx + floor(dw * 0.25), dy + 24, c_control_yellow, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], -no_limit, no_limit, 0, snapval, tab.camera.tbx_rotate_angle_xy, action_tl_frame_cam_rotate_angle_xy)
		axis_edit = X
		draw_wheel("frame_editor/camera/rotate/anglezwheel", dx + floor(dw * 0.75), dy + 24, c_control_cyan, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], -no_limit, no_limit, 0, snapval, tab.camera.tbx_rotate_angle_z, action_tl_frame_cam_rotate_angle_z)
		tab_next()
		
		// Textboxes
		axis_edit = setting_z_is_up ? Y : Z
		textfield_group_add(setting_z_is_up ? "frame_editor/camera/rotate/angle_xy" : "frame_editor/camera/rotate/angle_xz", tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], 0, action_tl_frame_cam_rotate_angle_xy, axis_edit, tab.camera.tbx_rotate_angle_xy, null, .1, -no_limit, no_limit)
		axis_edit = X
		textfield_group_add(setting_z_is_up ? "frame_editor/camera/rotate/angle_z" : "frame_editor/camera/rotate/angle_y", tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], 0, action_tl_frame_cam_rotate_angle_z, axis_edit, tab.camera.tbx_rotate_angle_z, null, .1, -no_limit, no_limit)
		
		tab_control_textfield_group()
		draw_textfield_group("frame_editor/camera/rotate/angle", dx, dy, dw, 0.1, 0, 0, snapval, false, true, 2)
		tab_next()
		
		// Distance
		tab_control_dragger()
		draw_dragger("frame_editor/camera/rotate/distance", dx, dy, dragger_width, tl_edit.value[e_value.CAM_ROTATE_DISTANCE], 1, 1, no_limit, 100, 0, tab.camera.tbx_rotate_distance, action_tl_frame_cam_rotate_distance)
		tab_next()
		
		// Look at
		tab_control_switch()
		draw_switch("frame_editor/camera/rotate/look_at_point", dx, dy, tab.camera.look_at_rotate, action_tl_frame_look_at_rotate)
		tab_next()
		
		tab_collapse_end()
	}
}
