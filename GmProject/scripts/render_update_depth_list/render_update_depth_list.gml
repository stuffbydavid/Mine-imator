function render_update_depth_list(owner)
{
	// Update shared list containing opaque objects that don't need sorting
	if (render_list_default_update)
	{
		ds_list_clear(render_list_default)
		ds_list_clear(render_list_custom)
		
		for (var pass = 0; pass < 2; pass++)
		for (var i = 0; i < ds_list_size(project_timeline_list); i++)
		{
			var tl, tlscenery;
			tl = project_timeline_list[|i]
			
			// Scenery is last in render list to optimize batching
			tlscenery = (tl.type = e_tl_type.SCENERY || tl.type = e_tl_type.STRUCTURE)
			if (tlscenery != (pass = 1))
				continue
			
			if ((tl.render_depth_custom_current && tl.render_depth_current = 0) ||
				(!tl.render_depth_custom_current && tl.value_inherit[e_value.ALPHA] >= 1))
				ds_list_add(render_list_default, tl)
			else
				ds_list_add(render_list_custom, tl)
		}
		
		render_list_default_update = false
		
		app.render_list_update = true
		
		with (obj_timeline)
			if (type = e_tl_type.CAMERA)
				render_list_update = true
		
		with (obj_view)
			render_list_update = true
	}
	
	if (is_string(owner))
		owner = app
	
	with (owner)
	{
		// Assign per-depth level list
		if (!is_array(render_depth_list))
			render_depth_list = [ ds_list_create(), ds_list_create() ]
	
		render_depth_list_current = render_depth_list

		// Check for camera change
		var prev = render_list_camera_from;
		if (!render_list_update && prev != null && vec3_equals(prev, cam_from))
			return 0
	
		ds_list_clear(render_depth_list[e_depth_list.NEGATIVE])
		ds_list_clear(render_depth_list[e_depth_list.POSITIVE])
	
		// Build lists from custom values and transparent objects
		var customcount = array_create(e_depth_list.amount, 0);
		for (var i = 0; i < ds_list_size(render_list_custom); i++)
		{
			var tl = render_list_custom[|i];
		
			// Insert objects with a custom value
			if (tl.render_depth_custom_current)
			{
				var index, list, pos;
				index = (tl.render_depth_current < 0) ? 0 : 1
				list = render_depth_list[index]
			
				pos = 0
				while (pos < customcount[index] && list[|pos].render_depth_current <= tl.render_depth_current)
					pos++
			
				ds_list_insert(list, pos, tl)
				customcount[index]++
			}
		
			// Sort transparent objects by camera distance
			else
			{
				var list, pos;
				list = render_depth_list[e_depth_list.POSITIVE]
				tl.render_sort_distance =
					sqr(tl.world_pos[X] - cam_from[X]) +
					sqr(tl.world_pos[Y] - cam_from[Y]) +
					sqr(tl.world_pos[Z] - cam_from[Z])
			
				pos = customcount[e_depth_list.POSITIVE]
				while (pos < ds_list_size(list) && list[|pos].render_sort_distance >= tl.render_sort_distance)
					pos++
			
				ds_list_insert(list, pos, tl)
			}
		}
	
		render_list_camera_from = point3D_copy(cam_from)
		render_list_update = false
	}
}
