/// tl_value_spawn()

if (type = e_tl_type.CAMERA)
{
	if (!app.setting_spawn_cameras)
		return 0
		
	value[e_value.POS_X] = app.cam_work_from[X]
	value[e_value.POS_Y] = app.cam_work_from[Y]
	value[e_value.POS_Z] = app.cam_work_from[Z]
	value[e_value.ROT_X] = -app.cam_work_angle_look_z
	value[e_value.ROT_Y] = app.cam_work_roll
	value[e_value.ROT_Z] = app.cam_work_angle_look_xy - 90
}
else if (parent = app && part_of = null && type != e_tl_type.FOLDER)
{
	if (!app.setting_spawn_objects)
		return 0
		
	value[e_value.POS_X] = app.cam_work_focus[X]
	value[e_value.POS_Y] = app.cam_work_focus[Y]
	value[e_value.POS_Z] = max(0, app.cam_work_focus[Z] - 16)
	
	if (type = e_temp_type.TEXT)
		value[e_value.POS_Z] += 16
}

value_default[e_value.POS_X] = value[e_value.POS_X]
value_default[e_value.POS_Y] = value[e_value.POS_Y]
value_default[e_value.POS_Z] = value[e_value.POS_Z]
value_default[e_value.ROT_X] = value[e_value.ROT_X]
value_default[e_value.ROT_Y] = value[e_value.ROT_Y]
value_default[e_value.ROT_Z] = value[e_value.ROT_Z]