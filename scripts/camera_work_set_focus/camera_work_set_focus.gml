/// camera_work_set_focus()

function camera_work_set_focus()
{
	cam_work_focus[X] = cam_work_from[X] + lengthdir_x(cam_work_zoom, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z)
	cam_work_focus[Y] = cam_work_from[Y] + lengthdir_y(cam_work_zoom, cam_work_angle_look_xy + 180) * lengthdir_x(1, cam_work_angle_look_z)
	cam_work_focus[Z] = cam_work_from[Z] + lengthdir_z(cam_work_zoom, cam_work_angle_look_z)
}
