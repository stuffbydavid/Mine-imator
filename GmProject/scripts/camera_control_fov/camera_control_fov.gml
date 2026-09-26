/// camera_control_fov(camera, lockx, locky)
/// @arg camera
/// @arg lockx
/// @arg locky

function camera_control_fov(cam, lockx, locky)
{
	var mx, my;
	mx = -((display_mouse_get_x() - lockx) / 4)
	my = ((display_mouse_get_y() - locky) / 4)
	display_mouse_set(lockx, locky)
	
	if (!cam)
	{
		cam_work_fov += my
		cam_work_fov = clamp(cam_work_fov, 10, 150)
		
		if (keybinds[e_keybind.CAM_RESET].pressed)
			camera_work_reset()
	}
	else
	{
		tl_value_set_start(camera_control_fov, true)
		tl_value_set(e_value.CAM_FOV, my, true)
		tl_value_set_done()
	}
}
