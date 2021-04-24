/// camera_work_set_angle()

function camera_work_set_angle()
{
	cam_work_angle_xy = point_direction(cam_work_focus[X], cam_work_focus[Y], cam_work_from[X], cam_work_from[Y])
	cam_work_angle_z = point_zdirection(cam_work_focus[X], cam_work_focus[Y], cam_work_focus[Z], cam_work_from[X], cam_work_from[Y], cam_work_from[Z])
	cam_work_zoom = point3D_distance(cam_work_focus, cam_work_from)
	cam_work_zoom_goal = cam_work_zoom
	cam_work_angle_off_xy = 0
	cam_work_angle_off_z = 0
}
