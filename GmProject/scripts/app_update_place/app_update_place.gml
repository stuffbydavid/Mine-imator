/// app_update_place()

function app_update_place()
{
	if (place_build && !view_main.mouseon && (!view_second.show || !view_second.mouseon))
	{
		action_build_structure(build_structure)
		place_target_tl = null
		place_view_pos = null
	}

	if (window_busy != place_busy)
		return 0
	
	if (!place_build)
		mouse_cursor = cr_drag
	
	// Camera moved > 1 unit, update depth caches
	if (vec3_length(vec3_sub(cam_work_from, place_cam_work_from)) > 1 ||
		place_cam_work_angle_look_xy != cam_work_angle_look_xy ||
		place_cam_work_angle_look_z != cam_work_angle_look_z)
	{
		view_main.update_place_surfaces = true
		view_second.update_place_surfaces = true
		place_cam_work_from = cam_work_from
		place_cam_work_angle_look_xy = cam_work_angle_look_xy
		place_cam_work_angle_look_z = cam_work_angle_look_z
	}
	
	// Update object with position from last step
	if (place_view_pos != null)
	{
		if (place_target_tl_part_of != null && instance_exists(place_target_tl_part_of))
			with (place_target_tl_part_of)
				tl_mark_place_target(false)

		place_target_tl = null
		place_target_tl_part_of = null
		place_pos = place_view_pos
		place_rot = vec3(0)
		
		build_box_render = null
		
		if (!place_build)
			action_tl_lock_tree(place_tl, false, null)
		
		if (!place_view_air)
		{
			// Find target parent
			if (place_view_color > 0 && instance_exists(place_view_color))
			{
				place_target_tl = place_view_color
				place_target_tl_part_of = place_view_color
			
				// Retrieve containing model
				if (place_target_tl.type = e_tl_type.MODEL_PART && place_target_tl.part_of != null)
					place_target_tl_part_of = place_target_tl.part_of
					
				// Adjust position/rotation by scenery
				app_update_place_scenery()

				// Find parent actions in build mode
				if (place_build)
				{
					var action = null;
					with (build_settings)
						action = tl_get_place_parent_action(app.place_target_tl)

					place_target_tl_part_of = null
					if (is_array(action) && array_length(action) > e_parent_action.TARGET)
					{
						var target = action[e_parent_action.TARGET];
						if (target != null && target != app)
						{
							if (type_is_structure(target.type))
								action_build_structure(target)
							else if (target.type = e_tl_type.MODEL_PART)
								place_target_tl_part_of = target
						}
					}
				}
			}
			
			// Ground placement
			else
			{
				var rotpoint = point3D(block_half_size, block_half_size, 0);
				if (place_build)
				{
					if (build_type = e_tl_type.BLOCK)
						rotpoint = build_settings.rot_point
				}
				else if (place_tl.type = e_tl_type.BLOCK || place_tl.type = e_tl_type.SCENERY)
					rotpoint = place_tl.rot_point_render

				place_pos[X] = snap(place_pos[X] - rotpoint[X], block_size) + rotpoint[X]
				place_pos[Y] = snap(place_pos[Y] - rotpoint[Y], block_size) + rotpoint[Y]
				place_pos[Z] = 0
				
				var boxpos = array_copy_1d(place_pos);
				boxpos[Z] -= block_half_size
				build_box_matrix = matrix_create(boxpos, vec3(0), vec3(1))
				build_box_render = build_box_top
			}
		}
			
		if (place_build)
		{
			if (place_target_tl_part_of = null)
				action_build_structure(build_structure)
			else
				with (place_target_tl_part_of)
					tl_mark_place_target(true)
			
			place_view_pos = null
			return 0
		}

		// Update timeline and parent to compatible objects
		tl_value_set_matrix(place_tl, matrix_create(place_pos, place_rot, place_sca), place_spawn)
		place_tl.update_matrix = true
		
		var newparent = null;
		if (place_target_tl != null)
		{
			with (place_tl)
			{
				var action = tl_get_place_parent_action(app.place_target_tl);
				if (is_array(action) && array_length(action) > e_parent_action.TARGET)
				{
					newparent = action[e_parent_action.TARGET]
					if (newparent != app)
					{
						app.place_target_tl_part_of = newparent
						with (newparent)
							tl_mark_place_target(true)
					}
					else
						app.place_target_tl_part_of = null
				}
			}
		}
		
		// Restore original parent/index
		var newparentindex = -1;
		if (newparent = null)
		{
			newparent = place_tl_parent
			newparentindex = place_tl_parent_index
		}
	
		// Parent to new or restore original parent
		var parentchanged = place_tl.parent != newparent;
		if (!parentchanged && newparentindex < 0)
			newparentindex = ds_list_find_index(newparent.tree_list, place_tl)
		
		with (place_tl)
			tl_set_parent(newparent, newparentindex, true)

		if (parentchanged)
			tl_update_list()
		tl_update_matrix()
		
		// Update history defaults
		with (place_history)
		{
			tl_value_copy_vec3(e_value.POS_X, value_default, app.place_tl.value_default)
			tl_value_copy_vec3(e_value.ROT_X, value_default, app.place_tl.value_default)
			tl_value_copy_vec3(e_value.SCA_X, value_default, app.place_tl.value_default)
		}
		
		place_view_pos = null
	}
		
	// Stop placing (no view clicked)
	if (!place_build && place_content_mouseon = null && mouse_left_released)
		app_cancel_place()
	
}
