/// @desc Returns the cached layered camera effects values for this scope.

function tl_camera_effects_get()
{
	if (camera_effect_enabled != null)
		return camera_effect_value
	
	camera_effect_value = null
	camera_effect_enabled = array_create(e_cam_fx.amount, false)
	camera_effect_scope = array_create(e_cam_fx.amount, null)
	camera_effect_aperture_scope = null

	// Apply global effects
	with (obj_timeline)
		if (type = e_tl_type.CAMERA_EFFECT)
			tl_camera_effect_apply(app)

	// Camera effects override global effects
	if (id != app)
		with (obj_timeline)
			if (type = e_tl_type.CAMERA_EFFECT)
				tl_camera_effect_apply(other.id)
	
	return camera_effect_value
}
