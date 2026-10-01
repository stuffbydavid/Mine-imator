/// @desc Returns the cached layered camera effects values.

function render_camera_effects_get()
{
	if (app.timeline_camera_effect_value != null)
		return app.timeline_camera_effect_value

	var assigned, values;
	assigned = array_create(e_cam_fx.amount, false)
	values = null
	
	with (obj_timeline)
	{
		if (type != e_tl_type.CAMERA_EFFECT || !value_inherit[e_value.VISIBLE] || hide)
			continue

		var fxtype = camera_effect_type;
		if (assigned[fxtype])
			continue
		
		if (values = null)
		{
			values = array_create(e_value.amount, false)
			for (var v = 0; v < e_value.amount; v++)
				values[v] = app.value_default[v]
		}
		
		var fxrange = camera_effect_value_range_list[|fxtype];
		for (var v = fxrange[0]; v <= fxrange[1]; v++)
			if (fxtype != e_cam_fx.FADE || v != e_value.GLOW_COLOR)
				values[v] = value[v]
		
		if (camera_effect_type_use_aperture(fxtype) && (fxtype = e_cam_fx.BLOOM || !assigned[e_cam_fx.BLOOM]))
			for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
				values[v] = value[v]

		if (fxtype = e_cam_fx.COLOR_CORRECTION)
			for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
				values[v] = value[v]
		
		if (fxtype = e_cam_fx.LENS_DIRT)
			values[e_value.TEXTURE_OBJ] = value[e_value.TEXTURE_OBJ]
		
		assigned[fxtype] = true
	}

	app.timeline_camera_effect_value = values
	app.timeline_camera_effect_enabled = assigned
	
	return values
}
