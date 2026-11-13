/// @arg direction

function camera_snap(dir)
{
	var xy, z;
	z = clamp(-point_zdirection(0, 0, 0, dir[X], dir[Y], dir[Z]), -pitch_limit, pitch_limit)
	
	if (dir[X] = 0 && dir[Y] = 0)
	{
		cam_work_angle_goal_xy = cam_work_angle_xy
		cam_work_angle_goal_z = -z
		cam_work_angle_goal_look_xy = cam_work_angle_look_xy
		cam_work_angle_goal_look_z = z
		return 0
	}
	
	xy = point_direction(0, 0, dir[X], dir[Y])
	
	// Clicking the same axis again looks from its opposite side
	if (abs(angle_difference_fix(xy, cam_work_angle_goal_look_xy)) < 0.05 && abs(z - cam_work_angle_goal_look_z) < 0.05)
	{
		xy += 180
		z = -z
	}
	
	cam_work_angle_goal_xy = cam_work_angle_xy + angle_difference_fix(xy, cam_work_angle_xy)
	cam_work_angle_goal_z = -z
	cam_work_angle_goal_look_xy = cam_work_angle_look_xy + angle_difference_fix(xy, cam_work_angle_look_xy)
	cam_work_angle_goal_look_z = z
}
