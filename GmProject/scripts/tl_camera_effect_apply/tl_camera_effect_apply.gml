/// @desc Applies a visible camera effect from the requested hierarchy scope.

function tl_camera_effect_apply(scope)
{
	if (type != e_tl_type.CAMERA_EFFECT || !value_inherit[e_value.VISIBLE] || hide)
		return 0

	// Find first camera in hierarchy (or app)
	var child, cam;
	child = id
	cam = parent
	while (cam != null && cam != app)
	{
		if (cam = app.timeline_move_obj)
		{
			cam = child.move_parent
			continue
		}
		
		if (cam.type = e_tl_type.CAMERA)
			break
		
		child = cam
		cam = cam.parent
	}
	
	if (cam = null)
		cam = app
	
	if (cam != scope)
		return 0

	if (other.camera_effect_enabled[camera_effect_type])
		return 0
	
	if (other.camera_effect_value = null)
	{
		other.camera_effect_value = array_create(e_value.amount, false)
		for (var v = 0; v < e_value.amount; v++)
			other.camera_effect_value[v] = app.value_default[v]
	}
	
	var fxrange = camera_effect_value_range_list[|camera_effect_type];
	for (var v = fxrange[0]; v <= fxrange[1]; v++)
		if (camera_effect_type != e_cam_fx.FADE || v != e_value.GLOW_COLOR)
			other.camera_effect_value[v] = value[v]
	
	if (camera_effect_type_use_aperture(camera_effect_type) &&
		(other.camera_effect_aperture_scope = null || (other.camera_effect_aperture_scope = scope && camera_effect_type = e_cam_fx.BLOOM)))
	{
		for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
			other.camera_effect_value[v] = value[v]
		
		other.camera_effect_aperture_scope = scope
	}

	if (camera_effect_type = e_cam_fx.COLOR_CORRECTION)
		for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
			other.camera_effect_value[v] = value[v]
	
	if (camera_effect_type = e_cam_fx.LENS_DIRT)
		other.camera_effect_value[e_value.TEXTURE_OBJ] = value[e_value.TEXTURE_OBJ]
	
	other.camera_effect_enabled[camera_effect_type] = true
}
