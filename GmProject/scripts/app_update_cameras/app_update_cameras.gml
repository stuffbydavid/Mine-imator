/// @desc Updates surface of all required cameras.

function app_update_cameras(renderer, movie)
{
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
		if (renderer = e_renderer.REALISTIC && render_samples > -1 && surface_exists(cam_surf))
		{
			cam_surf_required = false
			continue
		}
		*/
		
		// Render
		with (app)
		{
			var preveffects = render_effects;
			renderer_current = renderer
			render_effects = true
			render_start(other.cam_surf_tmp, other.id, other.id)
			
			render_use_samples = false
			
			if (renderer_current = e_renderer.REALISTIC || renderer_current = e_renderer.STANDARD)
				render_high()
			else
				render_low()
			
			other.cam_surf_tmp = render_done()
			render_effects = preveffects
		}
		
		// Re-use the same two surfaces
		cam_surf = surface_require(cam_surf, render_width, render_height)
		
		var tmp = cam_surf;
		cam_surf = cam_surf_tmp
		cam_surf_tmp = tmp
		
		cam_surf_required = false
	}
}
