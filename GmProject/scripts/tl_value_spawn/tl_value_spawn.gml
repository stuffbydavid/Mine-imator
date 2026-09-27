/// tl_value_spawn()

function tl_value_spawn()
{
	// Cameras copy the work camera
	if (type = e_tl_type.CAMERA)
	{
		if (!app.setting_spawn_cameras)
			return 0
		
		tl_value_set_vec3(e_value.POS_X, app.cam_work_from)
		tl_value_set_vec3(e_value.ROT_X, vec3(
			-app.cam_work_angle_look_z,
			app.cam_work_roll,
			app.cam_work_angle_look_xy - 90
		))
	}
	
	// Model part values
	else if (type = e_tl_type.MODEL_PART && model_part != null)
	{
		// Bending
		if (model_part.bend_part != null)
		{
			tl_value_set_vec3(e_value.BEND_ANGLE_X, model_part.bend_default_angle)
			inherit_bend = model_part.bend_inherit
		}
		
		// Locked state
		lock = model_part.locked
	}
	
	// Background objects inherit current settings
	else if (type = e_tl_type.BACKGROUND)
	{
		for (var v = e_value.BG_SKY_MOON_PHASE; v <= e_value.BG_BRIGHTNESS; v++)
			value[v] = tl_value_default(v)
	}
	
	// Disable SSAO on particles by default
	if (type = e_tl_type.PARTICLE_SPAWNER)
		ssao = false

	// Root items use a smaller default scale
	if (type = e_tl_type.ITEM && parent = app)
		tl_value_set_vec3(e_value.SCA_X, vec3(0.5))
	
	// Set rotation point to template's by default
	if (temp != null)
	{
		rot_point = temp.rot_point
		tl_update_rot_point()
	}
	
	// Set defaults
	for (var v = 0; v < e_value.amount; v++)
		value_default[v] = value[v]
	
	// Align scenery to the block grid
	if (type = e_tl_type.SCENERY && temp.scenery != null && (temp.scenery.ready || temp.scenery.type = e_res_type.FROM_WORLD))
	{
		if (temp.scenery.scenery_size[X] > 0 && temp.scenery.scenery_size[X] mod 2 = 1)
		{
			value_default[e_value.POS_X] += block_half_size
			value[e_value.POS_X] = value_default[e_value.POS_X]
		}
		if (temp.scenery.scenery_size[Y] > 0 && temp.scenery.scenery_size[Y] mod 2 = 1)
		{
			value_default[e_value.POS_Y] += block_half_size
			value[e_value.POS_Y] = value_default[e_value.POS_Y]
		}
	}
}
