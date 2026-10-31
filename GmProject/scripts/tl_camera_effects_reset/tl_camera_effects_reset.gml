function tl_camera_effects_reset()
{
	app.camera_effect_value = null
	app.camera_effect_enabled = null
	app.camera_effect_scope = null
	
	with (obj_timeline)
	{
		if (type = e_tl_type.CAMERA)
		{
			camera_effect_value = null
			camera_effect_enabled = null
			camera_effect_scope = null
		}
	}
}
