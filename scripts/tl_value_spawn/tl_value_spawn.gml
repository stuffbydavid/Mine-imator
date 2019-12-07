/// tl_value_spawn()

// Cameras copy the work camera
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

// Model part values
else if (type = e_tl_type.BODYPART && model_part != null)
{
	// Bending
	if (model_part.bend_part != null)
	{
		value[e_value.BEND_ANGLE_X] = model_part.bend_default_angle[X]
		value[e_value.BEND_ANGLE_Y] = model_part.bend_default_angle[Y]
		value[e_value.BEND_ANGLE_Z] = model_part.bend_default_angle[Z]
		inherit_bend = model_part.bend_inherit
	}
	
	// Locked state
	lock = model_part.locked
}

// Background objects inherit current settings
else if (type = e_tl_type.BACKGROUND)
{
	for (var v = e_value.BG_SKY_MOON_PHASE; v <= e_value.BG_TEXTURE_ANI_SPEED; v++)
		value[v] = tl_value_default(v)
}

// Spawn at work camera position
else if (parent = app && part_of = null && type != e_tl_type.FOLDER && value_type[e_value_type.POSITION])
{
	if (!app.setting_spawn_objects)
		return 0
	
	value[e_value.POS_X] = app.cam_work_focus[X]
	value[e_value.POS_Y] = app.cam_work_focus[Y]
	value[e_value.POS_Z] = max(0, app.cam_work_focus[Z] - 16)
	
	if (type = e_temp_type.TEXT)
		value[e_value.POS_Z] += 16
}

// Disable SSAO on particles by default
if (type = e_tl_type.PARTICLE_SPAWNER)
	ssao = false

// Set rotation point to template's by default
if (temp != null)
{
	rot_point = temp.rot_point
	tl_update_rot_point()
}

// Set defaults
for (var v = 0; v < e_value.amount; v++)
	value_default[v] = value[v]