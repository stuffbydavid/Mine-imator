/// cam_work_set_from()

cam_work_from[X] = cam_work_focus[X] + lengthdir_x(cam_work_zoom, cam_work_angle_xy) * lengthdir_x(1, cam_work_angle_z)
cam_work_from[Y] = cam_work_focus[Y] + lengthdir_y(cam_work_zoom, cam_work_angle_xy) * lengthdir_x(1, cam_work_angle_z)
cam_work_from[Z] = cam_work_focus[Z] + lengthdir_z(cam_work_zoom, cam_work_angle_z)
