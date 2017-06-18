/// project_read_camera()

cam_work_focus[X] = buffer_read_double()
cam_work_focus[Y] = buffer_read_double()
cam_work_focus[Z] = buffer_read_double()		debug("cam_work_focus", cam_work_focus[X], cam_work_focus[Y], cam_work_focus[Z])
cam_work_angle_xy = buffer_read_double()		debug("cam_work_angle_xy", cam_work_angle_xy)
cam_work_angle_z = buffer_read_double()			debug("cam_work_angle_z", cam_work_angle_z)
cam_work_roll = buffer_read_double()			debug("cam_work_roll", cam_work_roll)
cam_work_zoom = buffer_read_double()			debug("cam_work_zoom", cam_work_zoom)
cam_work_zoom_goal = cam_work_zoom

cam_work_angle_look_xy = cam_work_angle_xy
cam_work_angle_look_z = -cam_work_angle_z
cam_work_set_from()
