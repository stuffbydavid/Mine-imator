/// view_control_scale(view)
/// @arg view

function view_control_scale(view)
{
	var vlen, arrowstart, arrowend, mat;
	
	// Arrow length
	len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * view_control_ratio
	
	arrowstart = (setting_tool = e_view_tool.TRANSFORM ? len/4 : 0)
	arrowend = len * .45
	
	// Create matrix
	with (tl_edit)
	{
		if (scale_resize)
			mat = array_copy_1d(matrix)
		else
		{
			mat = array_copy_1d(matrix_parent)
			mat = matrix_multiply(matrix_create(point3D(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z]), vec3(0), vec3(1)), mat)
		}
		
		matrix_remove_scale(mat)
	}
	
	if (view_control_matrix != null && view_control_edit != null)
		mat = view_control_matrix
	
	// All axes
	if (setting_tool != e_view_tool.TRANSFORM)
		view_control_scale_all(view, mat, len * .6)
	
	// Draw each axis
	view_control_scale_axis(view, e_view_control.SCA_X, e_value.SCA_X, c_control_red, vec3(arrowstart, 0, 0), arrowend, mat, X, vec3(0, -90, 0))
	view_control_scale_axis(view, e_view_control.SCA_Y, e_value.SCA_Y, (setting_z_is_up ? c_control_green : c_control_blue), vec3(0, arrowstart, 0), arrowend, mat, Y, vec3(90, 0, 0))
	view_control_scale_axis(view, e_view_control.SCA_Z, e_value.SCA_Z, (setting_z_is_up ? c_control_blue : c_control_green), vec3(0, 0, arrowstart), arrowend, mat, Z, vec3(0))
	
	// Is dragging
	if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.SCA_X && view_control_edit <= e_view_control.SCA_Z)
	{
		mouse_cursor = cr_handpoint
		
		// Move
		var veclen = vec2_length(view_control_vec)
		if (veclen > 0 && !mouse_still)
		{
			var vecmouse, vecdot, move, snapval, newval;
			axis_edit = view_control_edit - e_view_control.SCA_X
			
			// Find move factor
			vecmouse = vec2(mouse_dx, mouse_dy)
			vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
			view_control_move_distance += ((vec2_length(vecmouse) / veclen) * len * vecdot) * .05 * dragger_multiplier
			
			snapval = (dragger_snap ? setting_snap_size_scale : snap_min)
			move = view_control_move_distance
			
			if (!setting_snap_absolute && dragger_snap)
				move = snap(move, snapval)
			
			newval = view_control_value + move
			newval = tl_value_clamp(e_value.SCA_X + axis_edit, newval)
			
			if (setting_snap_absolute || !dragger_snap)
				newval = snap(newval, snapval)
			
			newval -= tl_edit.value[e_value.SCA_X + axis_edit]
			
			// Update
			tl_value_set_start(action_tl_frame_scale, true)
			tl_value_set(e_value.SCA_X + axis_edit, newval, true)
			tl_value_set_done()
		}
		
		// Release
		if (!mouse_left)
		{
			window_busy = ""
			view_control_edit = null
			view_control_matrix = null
			view_control_length = null
			view_control_move_distance = 0
		}
	}
	
	// Is dragging(XYZ scale)
	if (view_control_edit_view = view && view_control_edit = e_view_control.SCA_XYZ)
	{
		mouse_cursor = cr_handpoint
		
		// Move
		if (!mouse_still)
		{
			var snapval, scaleval;
			snapval = (dragger_snap ? setting_snap_size_scale : snap_min)
			scaleval = view_control_scale_amount
			
			if (!setting_snap_absolute && dragger_snap)
				scaleval = snap(scaleval, snapval)
			
			scaleval = view_control_value_scale[X] * scaleval
			scaleval = tl_value_clamp(e_value.SCA_X, scaleval)
			
			if (setting_snap_absolute || !dragger_snap)
				scaleval = snap(scaleval, snapval)
			
			scaleval -= tl_edit.value[e_value.SCA_X]
			
			// Update
			axis_edit = X
			action_tl_frame_scale_all_axis(scaleval, true)
		}
		
		// Release
		if (!mouse_left)
		{
			window_busy = ""
			view_control_edit = null
			view_control_scale_amount = 1
			view_control_matrix = null
			view_control_length = null
			view_control_value = 0
		}
	}
}
