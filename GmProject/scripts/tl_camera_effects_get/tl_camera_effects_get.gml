/// @desc Returns the cached layered camera effects values for this scope.

function tl_camera_effects_get()
{
	if (camera_effect_enabled != null)
		return camera_effect_value
	
	camera_effect_value = null
	camera_effect_enabled = array_create(e_cam_fx.amount, false)
	camera_effect_aperture_scope = null
		
	// Apply camera effects from child objects
	if (id != app)
		with (obj_timeline)
			if (type = e_tl_type.CAMERA_EFFECT)
				tl_camera_effect_apply(other.id)
		
	// Apply global effects
	with (obj_timeline)
		if (type = e_tl_type.CAMERA_EFFECT)
			tl_camera_effect_apply(app)
	
	return camera_effect_value
}
