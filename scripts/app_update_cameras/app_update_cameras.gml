/// app_update_cameras(highquality)
/// @arg highquality
/// @desc Updates surface of all required cameras.

// Only main view is visible and not real time rendering, no need to update
if (!view_second.show && view_render && !view_render_real_time && !exportmovie)
	return 0

with (obj_timeline)
{
	if (!value_inherit[e_value.VISIBLE] || !type_is_shape(type))
		continue
	
	var texobj;
	if (value_inherit[e_value.TEXTURE_OBJ] != null)
		texobj = value_inherit[e_value.TEXTURE_OBJ]
	else
		texobj = temp.shape_tex
	
	if (texobj != null && texobj.type = "camera")
		texobj.cam_surf_required = true
}

with (obj_particle)
{
	if (!type.temp || !type_is_shape(type.temp.type))
		continue
		
	if (type.temp.shape_tex && type.temp.shape_tex.type = "camera")
		type.temp.shape_tex.cam_surf_required = true
}

with (obj_timeline)
{
	if (type != "camera" || !cam_surf_required)
		continue
	
	// Render
	with (app)
	{
		render_start(other.cam_surf_tmp, other.id)
		if (argument0)
			render_high()
		else
			render_low()
		other.cam_surf_tmp = render_done()
	}
	
	// Re-use the same two surfaces
	cam_surf = surface_require(cam_surf, app.render_width, app.render_height)
	
	var tmp = cam_surf;
	cam_surf = cam_surf_tmp
	cam_surf_tmp = tmp
	
	cam_surf_required = false
}
