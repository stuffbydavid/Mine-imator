/// camera_control_rotate(camera, lockx, locky)
/// @arg camera
/// @arg lockx
/// @arg locky

function camera_control_rotate(cam, lockx, locky)
{
	var mx, my;
	mx = -((display_mouse_get_x() - lockx) / 4)
	my = ((display_mouse_get_y() - locky) / 4)
	display_mouse_set(lockx, locky)
	
	if (!cam)
	{
		if (fps > 30 && setting_smooth_camera)
		{
			cam_work_angle_off_xy += mx / (2 / delta)
			cam_work_angle_off_z += my / (2 / delta)
		}
		else
		{
			cam_work_angle_off_xy = 0
			cam_work_angle_off_z = 0
		
			cam_work_angle_xy += mx
			cam_work_angle_z += my
			cam_work_angle_z = clamp(cam_work_angle_z, -89.9, 89.9)
	
			cam_work_angle_look_xy += mx
			cam_work_angle_look_z -= my
			cam_work_angle_look_z = clamp(cam_work_angle_look_z, -89.9, 89.9)
			camera_work_set_from()
		}
		
		if (keybinds_map[?e_keybind.CAM_RESET].pressed)
			camera_work_reset()
	}
	else
	{
		tl_value_set_start(camera_control_rotate, true)
		tl_value_set(e_value.CAM_ROTATE_ANGLE_XY, mx, true)
		tl_value_set(e_value.CAM_ROTATE_ANGLE_Z, my, true)
		
		if (frame_editor.camera.look_at_rotate)
		{
			tl_value_set(e_value.ROT_Z, cam.value[e_value.CAM_ROTATE_ANGLE_XY], false)
			tl_value_set(e_value.ROT_X, cam.value[e_value.CAM_ROTATE_ANGLE_Z], false)
		}
		
		tl_value_set_done()
	}
}
