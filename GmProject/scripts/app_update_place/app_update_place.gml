function app_update_place()
{
	if (window_busy != place_busy)
		return 0
	
	// Placement mode
	if (!place_build)
	{
		// Stop placing (no view clicked)
		if (place_content_mouseon = null && mouse_left_released)
		{
			app_cancel_place()
			return 0
		}
	}
	
	// Build mode
	else
	{
		// Restore structure
		if (!view_main.mouseon && (!view_second.show || !view_second.mouseon))
		{
			action_build_structure(build_structure)
		
			place_target_tl = null
			place_view_pos = null
		}
	}
	
	if (place_view_pos = null)
		return 0
	
	// Update placed object or build wireframe box with place data from the previous render
	var oldpos, oldrot, oldtlroot, oldboxmat, oldboxrender;
	oldpos = place_pos != null ? point3D_copy(place_pos) : null
	oldrot = point3D_copy(place_rot)
	oldtlroot = place_target_tl_root
	oldboxmat = build_box_matrix
	oldboxrender = build_box_render

	place_target_tl = null
	place_target_tl_root = null
	place_pos = place_view_pos
	place_rot = vec3(0)
	build_box_render = null
		
	if (!place_build)
		action_tl_lock_tree(place_tl, false, null)
		
	if (!place_view_air)
	{
		// Find target parent
		if (place_view_tl > 0 && instance_exists(place_view_tl))
		{
			place_target_tl = place_view_tl
			place_target_tl_root = place_view_tl
			
			// Retrieve containing model
			if (place_target_tl.type = e_tl_type.MODEL_PART && place_target_tl.part_of != null)
				place_target_tl_root = place_target_tl.part_of
					
			// Adjust position/rotation by scenery
			app_update_place_scenery()

			// Find parent actions in build mode
			if (place_build)
			{
				var action = null;
				with (build_settings)
					action = tl_get_place_parent_action(app.place_target_tl)

				place_target_tl_root = null
					
				if (is_array(action) && array_length(action) > e_parent_action.TARGET)
				{
					var target = action[e_parent_action.TARGET];
					if (target != null && target != app)
					{
						// Assign new structure
						if (type_is_structure(target.type) && !build_structure_custom)
						{
							build_structure = target
							place_target_tl_root = target
						}
							
						// Assign model part
						else if (target.type = e_tl_type.MODEL_PART)
							place_target_tl_root = target
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
		
	var newparent, newparentindex, parentchanged;
	newparent = null
	newparentindex = -1
			
	// Placement mode
	if (!place_build)
	{
		// Adjust text/lights
		if (place_tl.type = e_tl_type.TEXT)
			app_update_place_text()
		else if (type_is_light(place_tl.type))
			place_pos[Z] += block_size
			
		// Find new parent 
		var action = null;
		if (place_target_tl != null)
			with (place_tl)
				action = tl_get_place_parent_action(app.place_target_tl)
			
		if (is_array(action) && array_length(action) > e_parent_action.TARGET)
			newparent = action[e_parent_action.TARGET]
			
		place_target_tl_root = (newparent != app ? newparent : null)
			
		// Ignore unchanged picks
		if (oldpos != null && vec3_equals(oldpos, place_pos) && vec3_equals(oldrot, place_rot) && oldtlroot = place_target_tl_root)
		{
			place_view_pos = null
			return 0
		}
	}
	
	// Build mdoe
	else
	{
		// No object on cursor
		if (place_target_tl_root = null)
		{
			if (build_structure != null && !instance_exists(build_structure))
				build_structure = null
				
			// Return to chosen structure
			place_target_tl_root = build_structure
		}
	}
		
	// Mark new target parent
	if (oldtlroot != place_target_tl_root)
	{
		if (oldtlroot != null && instance_exists(oldtlroot))
			with (oldtlroot)
				tl_mark_place_target(false)
			
		if (place_target_tl_root != null)
			with (place_target_tl_root)
				tl_mark_place_target(true)
	}
		
	if (place_build)
	{
		if (oldboxrender != build_box_render || (build_box_render != null && !matrix_equals(oldboxmat, build_box_matrix)))
		{
			render_samples = -1
			if (oldtlroot = place_target_tl_root)
				view_changed(build_first_person ? view_main : null)
		}
		
		place_view_pos = null
		
		return 0
	}

	// Update timeline and parent to compatible objects
	tl_value_set_matrix(place_tl, matrix_create(place_pos, place_rot, place_sca), place_spawn)
	place_tl.update_matrix = true
		
	// Restore original parent/index
	if (newparent = null)
	{
		newparent = place_tl_parent
		newparentindex = place_tl_parent_index
	}
	
	// Parent to new or restore original parent
	parentchanged = (place_tl.parent != newparent)
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
	
	// Force re-render in Realistic mode
	render_samples = -1
}
