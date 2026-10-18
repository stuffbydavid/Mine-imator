/// @arg direction

function camera_snap(dir)
{
	var tempangle = [cam_work_angle_goal_look_xy, cam_work_angle_goal_look_z];
	cam_work_angle_goal_look_xy = point_direction(cam_work_focus[X], cam_work_focus[Y],
			cam_work_focus[X] + dir[X],
			cam_work_focus[Y] + dir[Y]
	)
	cam_work_angle_goal_look_z = -point_zdirection(cam_work_focus[X], cam_work_focus[Y], cam_work_focus[Z],
			cam_work_focus[X] + dir[X],
			cam_work_focus[Y] + dir[Y],
			cam_work_focus[Z] + dir[Z]
	)
	cam_work_angle_goal_look_z = clamp(cam_work_angle_goal_look_z, -pitch_limit, pitch_limit)
	
	// Invert goal angle if identical to current angle
	if (cam_work_angle_goal_look_xy = tempangle[X] && cam_work_angle_goal_look_z = tempangle[Y])
	{
		cam_work_angle_goal_look_xy = mod_fix(cam_work_angle_goal_look_xy + 180, 360)
		cam_work_angle_goal_look_z = cam_work_angle_goal_look_z * -1
	}
	
	// Set XY angle to 0 for Z (up/down) axis
	if (dir[X] = 0 && dir[Y] = 0)
		cam_work_angle_goal_look_xy = 0
	
	// Fix smooth rotation when goal value wraps around
	// hacky C++ fix: [0 - 360] -> [-180 - 180]
	if (cam_work_angle_goal_look_xy <= (is_cpp() ? -90 : 90) && tempangle[X] >= (is_cpp() ? 90 : 270))
	{
		cam_work_angle_xy -= 360
		cam_work_angle_look_xy -= 360
	}
	else if (cam_work_angle_goal_look_xy >= (is_cpp() ? 90 : 270) && tempangle[X] <= (is_cpp() ? -90 : 90))
	{
		cam_work_angle_xy += 360
		cam_work_angle_look_xy += 360
	}
	
	cam_work_angle_goal_xy = cam_work_angle_goal_look_xy
	cam_work_angle_goal_z = -cam_work_angle_goal_look_z
	
	camera_work_set_from()
}
