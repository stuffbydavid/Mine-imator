/// app_start_place(tl, spawn)
function app_start_place(tl, spawn)
{
	window_busy = "place"
	place_tl = tl
	place_tl_render = false
	place_spawn = spawn
	
	view_main.update_place_surfaces = true
	view_main.place_depth_value = 0.995
	view_second.update_place_surfaces = true
	view_second.place_depth_value = 0.995
	
	with (place_tl)
		tl_mark_placed(true)
}

/// app_stop_place()
function app_stop_place()
{
	with (place_tl)
		tl_mark_placed(false)
		
	place_tl = null
	window_busy = ""
	mouse_clear(mb_left)
}

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
		/*var snappos = setting_snap;
		if (keyboard_check(vk_shift))
			snappos = !snappos
		
		if (snappos)
		{
			place_view_pos[X] = snap(place_view_pos[X], setting_snap_size_position)
			place_view_pos[Y] = snap(place_view_pos[Y], setting_snap_size_position)
			place_view_pos[Z] = snap(place_view_pos[Z], setting_snap_size_position)
		}*/
	
		// Update timeline
		with (place_tl)
		{
			tl_value_set_vec3(e_value.POS_X, app.place_view_pos)
			tl_value_set_vec3(e_value.ROT_X, app.place_view_rot)
			tl_value_set_vec3(e_value.SCA_X, app.place_view_sca)
				
			// Defaults
			if (app.place_spawn)
			{
				tl_value_set_vec3(e_value.POS_X, app.place_view_pos, true)
				tl_value_set_vec3(e_value.ROT_X, app.place_view_rot, true)
				tl_value_set_vec3(e_value.SCA_X, app.place_view_sca, true)
			}
			
			update_matrix = true
		}
		tl_update_matrix()
		
		// Update history defaults
		with (history[0])
		{
			tl_value_set_vec3(e_value.POS_X, app.place_view_pos, true)
			tl_value_set_vec3(e_value.ROT_X, app.place_view_rot, true)
			tl_value_set_vec3(e_value.SCA_X, app.place_view_sca, true)
		}
			
		place_view_pos = null
	}
		
	// Stop placing (no view clicked)
	if (place_view_mouse = null && mouse_left_released)
	{
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

function tl_mark_placed(active)
{
	placed = active
	
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			parent_is_placed = active
			tl_mark_placed(active)
		}
	}
}

function action_setting_place_new(argument0)
{
	setting_place_new = argument0
}
