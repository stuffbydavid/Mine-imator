/// camera_control_move(camera, lockx, locky)
/// @arg camera
/// @arg lockx
/// @arg locky

function camera_control_move(cam, lockx, locky)
{
	var mx, my;
	mx = -((display_mouse_get_x() - lockx) / 8) * setting_look_sensitivity
	my = -((display_mouse_get_y() - locky) / 8) * setting_look_sensitivity
	display_mouse_set(lockx, locky)
	
	if (!cam)
	{
		var move, spd, spdm, xd, yd, zd;
		
		cam_work_angle_look_xy += mx
		cam_work_angle_look_z += my
		cam_work_angle_look_z = clamp(cam_work_angle_look_z, -89.9, 89.9)
		
		if (!cam_work_focus_tl)
		{
			camera_work_set_focus()
			camera_work_set_angle()
		}
		
		// Move
		move = 4 * setting_move_speed * delta
		spd = (keybinds_map[?e_keybind.CAM_FORWARD].active - keybinds_map[?e_keybind.CAM_BACK].active) * move
		spdm = 1
		if (keybinds_map[?e_keybind.CAM_FAST].active)
			spdm = setting_fast_modifier
		if (keybinds_map[?e_keybind.CAM_SLOW].active)
			spdm = setting_slow_modifier
		
		if (keybinds_map[?e_keybind.CAM_RIGHT].active)
		{
			xd = -sin(degtorad(cam_work_angle_look_xy)) * move
			yd = -cos(degtorad(cam_work_angle_look_xy)) * move
		}
		else if (keybinds_map[?e_keybind.CAM_LEFT].active)
		{
			xd = sin(degtorad(cam_work_angle_look_xy)) * move
			yd = cos(degtorad(cam_work_angle_look_xy)) * move
		}
		else
		{
			xd = 0
			yd = 0
		}
		
		xd += -lengthdir_x(spd, cam_work_angle_look_xy)
		yd += -lengthdir_y(spd, cam_work_angle_look_xy)
		zd = (keybinds_map[?e_keybind.CAM_ASCEND].active - keybinds_map[?e_keybind.CAM_DESCEND].active) * move
		zd += (dsin(cam_work_angle_look_z)) * (keybinds_map[?e_keybind.CAM_FORWARD].active - keybinds_map[?e_keybind.CAM_BACK].active) * move
		
		cam_work_from[X] += xd * spdm
		cam_work_from[Y] += yd * spdm
		cam_work_from[Z] += zd * spdm
		
		if (!cam_work_focus_tl)
		{
			cam_work_focus[X] += xd * spdm
			cam_work_focus[Y] += yd * spdm
			cam_work_focus[Z] += zd * spdm
		}
		
		// Reset
		if (keybinds_map[?e_keybind.CAM_RESET].pressed)
			camera_work_reset()
		
		camera_work_set_angle()
	}
	else
	{
		var move, roll, spd, spdm, xd, yd, zd;
		
		// Move
		move = 4 * setting_move_speed * delta
		spd = (keybinds_map[?e_keybind.CAM_FORWARD].active - keybinds_map[?e_keybind.CAM_BACK].active) * move
		spdm = 1
		if (keybinds_map[?e_keybind.CAM_FAST].active)
			spdm = setting_fast_modifier
		if (keybinds_map[?e_keybind.CAM_SLOW].active) 
			spdm = setting_slow_modifier
		
		if (keybinds_map[?e_keybind.CAM_RIGHT].active)
		{
			xd = -sin(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
			yd = -cos(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
		}
		else if (keybinds_map[?e_keybind.CAM_LEFT].active)
		{
			xd = sin(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
			yd = cos(degtorad(cam.value[e_value.ROT_Z] + 90)) * move
		}
		else
		{
			xd = 0
			yd = 0
		}
		
		xd += -lengthdir_x(spd, cam.value[e_value.ROT_Z] + 90)
		yd += -lengthdir_y(spd, cam.value[e_value.ROT_Z] + 90)
		zd = (keybinds_map[?e_keybind.CAM_ASCEND].active - keybinds_map[?e_keybind.CAM_DESCEND].active) * move
		zd += (-dsin(cam.value[e_value.ROT_X])) * (keybinds_map[?e_keybind.CAM_FORWARD].active - keybinds_map[?e_keybind.CAM_BACK].active) * move
		
		// Roll
		roll = (keybinds_map[?e_keybind.CAM_ROLL_FORWARD].active - keybinds_map[?e_keybind.CAM_ROLL_BACK].active) * 4 * spdm * delta
		
		// Set
		tl_value_set_start(camera_control_move, true)
		tl_value_set(e_value.POS_X, xd * spdm, true)
		tl_value_set(e_value.POS_Y, yd * spdm, true)
		tl_value_set(e_value.POS_Z, zd * spdm, true)
		tl_value_set(e_value.ROT_X, -my, true)
		tl_value_set(e_value.ROT_Y, roll, true)
		tl_value_set(e_value.ROT_Z, mx, true)
		
		if (keybinds_map[?e_keybind.CAM_ROLL_RESET].active)
			tl_value_set(e_value.ROT_Y, 0, false)
		
		tl_value_set_done()
	}
}
