/// app_update_cameras(highquality, movie)
/// @arg highquality
/// @arg movie
/// @desc Updates surface of all required cameras.

function app_update_cameras(highquality, movie)
{
	// Only main view is visible and not real time rendering, no need to update
	if (!view_second.show && view_render && !view_render_real_time && window_state != "export_movie" && window_state != "export_image" && !movie)
		return 0
	
	with (obj_timeline)
	{
		if (!render_visible || !type_is_shape(type))
			continue
		
		var texobj;
		if (value_inherit[e_value.TEXTURE_OBJ] > 0)
			texobj = value_inherit[e_value.TEXTURE_OBJ]
		else
			texobj = temp.shape_tex
		
		if (texobj != null && texobj.type = e_tl_type.CAMERA)
			texobj.cam_surf_required = true
	}
	
	with (obj_particle)
	{
		if (type.temp = particle_sheet || type.temp = particle_template || !type_is_shape(type.temp.type))
			continue
		
		if (type.temp.shape_tex != null && type.temp.shape_tex.type = e_tl_type.CAMERA)
			type.temp.shape_tex.cam_surf_required = true
	}
	
	with (obj_timeline)
	{
		if (type != e_tl_type.CAMERA || !cam_surf_required)
			continue
		
		/*
		// Only update surface if needed
		if (highquality && render_samples > -1 && surface_exists(cam_surf))
		{
			cam_surf_required = false
			continue
		}
		*/
		
		// Render
		with (app)
		{
			render_start(other.cam_surf_tmp, other.id)
			if (highquality)
				render_high()
			else
				render_low()
			other.cam_surf_tmp = render_done()
		}
		
		// Re-use the same two surfaces
		cam_surf = surface_require(cam_surf, render_width, render_height)
		
		var tmp = cam_surf;
		cam_surf = cam_surf_tmp
		cam_surf_tmp = tmp
		
		cam_surf_required = false
	}
}
