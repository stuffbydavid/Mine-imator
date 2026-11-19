/// @arg direction

function camera_snap(dir)
{
	var xy, zz;
	zz = clamp(-point_zdirection(0, 0, 0, dir[X], dir[Y], dir[Z]), -pitch_limit, pitch_limit)
	
	xy = point_direction(0, 0, dir[X], dir[Y])
	
	// Clicking the same axis again looks from its opposite side
	var margin = 1;
	if ((abs(cam_work_angle_goal_look_z) > pitch_limit - margin || abs(angle_difference_fix(xy, cam_work_angle_goal_look_xy)) < margin) && abs(zz - cam_work_angle_goal_look_z) < margin)
	{
		xy += 180
		zz = -zz
	}
	
	if (dir[X] = 0 && dir[Y] = 0)
	{
		cam_work_angle_goal_xy = cam_work_angle_xy
		cam_work_angle_goal_z = -zz
		cam_work_angle_goal_look_xy = cam_work_angle_look_xy
		cam_work_angle_goal_look_z = zz
		return 0
	}
	
	cam_work_angle_goal_xy = cam_work_angle_xy + angle_difference_fix(xy, cam_work_angle_xy)
	cam_work_angle_goal_z = -zz
	cam_work_angle_goal_look_xy = cam_work_angle_look_xy + angle_difference_fix(xy, cam_work_angle_look_xy)
	cam_work_angle_goal_look_z = zz
}
