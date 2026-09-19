/// app_update_place()

function app_update_place()
{
	if (window_busy != "place")
		return 0
	
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
		place_target_tl = null
		place_pos = place_view_pos
		place_rot = vec3(0)
		place_sca = vec3(1)
		
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
			}
			
			// Ground placement
			else
			{
				var rotpoint = point3D(block_half_size, block_half_size, 0);
				if (place_tl.type = e_tl_type.BLOCK || place_tl.type = e_tl_type.SCENERY)
					rotpoint = place_tl.rot_point_render

				place_pos[X] = snap(place_pos[X] - rotpoint[X], block_size) + rotpoint[X]
				place_pos[Y] = snap(place_pos[Y] - rotpoint[Y], block_size) + rotpoint[Y]
				place_pos[Z] = 0
			}
		}
			
		// Parent to compatible objects
		app_update_place_parent()
	
		// Update timeline
		tl_value_set_matrix(place_tl, matrix_create(place_pos, place_rot, place_sca), place_spawn)
		place_tl.update_matrix = true
		tl_update_matrix()
		
		// Update history defaults
		with (history[0])
		{
			tl_value_set_vec3(e_value.POS_X, app.place_pos, true)
			tl_value_set_vec3(e_value.ROT_X, app.place_rot, true)
			tl_value_set_vec3(e_value.SCA_X, app.place_sca, true)
		}
			
		place_view_pos = null
	}
		
	// Stop placing (no view clicked)
	if (place_view_mouse = null && mouse_left_released)
	{
		if (place_tl.parent != place_tl_parent)
		{
			with (place_tl)
				tl_set_parent(place_tl_parent, place_tl_parent_index, true)
			tl_update_list()
		}

		with (history[0])
		{
			tl_value_set_vec3(e_value.POS_X, vec3(0), true)
			tl_value_set_vec3(e_value.ROT_X, vec3(0), true)
			tl_value_set_vec3(e_value.SCA_X, vec3(1), true)
		}
		
		with (place_tl)
		{
			tl_value_set_vec3(e_value.POS_X, vec3(0))
			tl_value_set_vec3(e_value.POS_X, vec3(0), true)
			tl_value_set_vec3(e_value.ROT_X, vec3(0))
			tl_value_set_vec3(e_value.ROT_X, vec3(0), true)
			tl_value_set_vec3(e_value.SCA_X, vec3(1))
			tl_value_set_vec3(e_value.SCA_X, vec3(1), true)
			update_matrix = true
		}
		
		tl_update_matrix()
		render_samples = -1
		app_stop_place()
	}
	
	place_view_mouse = null
}