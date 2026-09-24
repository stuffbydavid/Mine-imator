/// view_control_rotate(view)
/// @arg view

function view_control_rotate(view)
{
	var len, xrot, yrot, zrot;
	len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * 0.6
	
	var transform_mode = view_transform_mode_effective(e_value_type.TRANSFORM_ROT);

	// Create matrices
	if (transform_mode = e_transform_mode.GLOBAL)
	{
		zrot = matrix_build(tl_edit.world_pos[X], tl_edit.world_pos[Y], tl_edit.world_pos[Z], 0, 0, 0, 1, 1, 1)
	}
	else if (transform_mode = e_transform_mode.LOCAL)
	{
		var local_euler = vec3(tl_edit.value[e_value.ROT_X], tl_edit.value[e_value.ROT_Y], tl_edit.value[e_value.ROT_Z])
		var local_rotation = matrix_build(0, 0, 0, local_euler[X], local_euler[Y], local_euler[Z], 1, 1, 1)
		var parent_rotation = view_rotation_matrix_orthonormal(view_rotation_parent_matrix(tl_edit))
		zrot = view_rotation_matrix_orthonormal(matrix_multiply(local_rotation, parent_rotation))
		zrot[MAT_X] = tl_edit.world_pos[X]
		zrot[MAT_Y] = tl_edit.world_pos[Y]
		zrot[MAT_Z] = tl_edit.world_pos[Z]
	}
	else with (tl_edit)
	{
		zrot = array_copy_1d(matrix_parent)
		zrot[MAT_X] = matrix[MAT_X]
		zrot[MAT_Y] = matrix[MAT_Y]
		zrot[MAT_Z] = matrix[MAT_Z]
		matrix_remove_scale(zrot)
	}

	if (transform_mode = e_transform_mode.GIMBAL)
	{
		xrot = matrix_multiply(matrix_build(0, 0, 0, 0, -90, tl_edit.value[e_value.ROT_Z], 1, 1, 1), zrot)
		yrot = matrix_multiply(matrix_build(0, 0, 0, tl_edit.value[e_value.ROT_X] + 90, 0, tl_edit.value[e_value.ROT_Z], 1, 1, 1), zrot)
	}
	else
	{
		xrot = matrix_multiply(matrix_build(0, 0, 0, 0, -90, 0, 1, 1, 1), zrot)
		yrot = matrix_multiply(matrix_build(0, 0, 0, 90, 0, 0, 1, 1, 1), zrot)
	}

	// Keep Gimbal's established RGB palette. Global uses complementary world
	// colors, while Local uses lighter axis colors so the active basis is also
	// visible directly on the gizmo.
	var color_x = c_control_red;
	var color_y = setting_z_is_up ? c_control_green : c_control_blue;
	var color_z = setting_z_is_up ? c_control_blue : c_control_green;
	if (transform_mode = e_transform_mode.GLOBAL)
	{
		color_x = c_control_cyan
		color_y = setting_z_is_up ? c_control_magenta : c_control_yellow
		color_z = setting_z_is_up ? c_control_yellow : c_control_magenta
	}
	else if (transform_mode = e_transform_mode.LOCAL)
	{
		color_x = merge_color(c_control_red, c_control_white, .45)
		color_y = merge_color(setting_z_is_up ? c_control_green : c_control_blue, c_control_white, .45)
		color_z = merge_color(setting_z_is_up ? c_control_blue : c_control_green, c_control_white, .45)
	}
	
	// Draw each axis
	view_control_rotate_axis(view, e_view_control.ROT_X, e_value.ROT_X, color_x, xrot, len)
	view_control_rotate_axis(view, e_view_control.ROT_Y, e_value.ROT_Y, color_y, yrot, len)
	view_control_rotate_axis(view, e_view_control.ROT_Z, e_value.ROT_Z, color_z, zrot, len)
	
	// Is dragging
	if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.ROT_X && view_control_edit <= e_view_control.ROT_Z)
	{
		mouse_cursor = cr_handpoint
		
		if (!mouse_still)
		{
			var ang, prevang, rot, snapval, axesang, newval;
			axis_edit = view_control_edit - e_view_control.ROT_X
			
			// Find rotate amount
			ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
			prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
			rot = angle_difference_fix(ang, prevang) * negate(view_control_flip)
			view_control_move_distance += rot * dragger_multiplier
			
			snapval = (dragger_snap ? setting_snap_size_rotation : snap_min)
			axesang = view_control_move_distance
			
			if (!setting_snap_absolute && dragger_snap)
				axesang = snap(axesang, snapval)
			
			var transform_mode_angle = axesang;
			if (setting_snap_absolute || !dragger_snap)
				transform_mode_angle = snap(view_control_value + transform_mode_angle, snapval) - view_control_value

			newval = view_control_value + axesang
			newval = tl_value_clamp(e_value.ROT_X + axis_edit, newval)
			
			if (setting_snap_absolute || !dragger_snap)
				newval = snap(newval, snapval)
			
			newval -= tl_edit.value[e_value.ROT_X + axis_edit]
			
			// Update
			if (view_control_transform_mode = e_transform_mode.GIMBAL)
			{
				tl_value_set_start(action_tl_frame_rot, true)
				tl_value_set(e_value.ROT_X + axis_edit, newval, true)
				tl_value_set_done()
			}
			else
				view_rotation_apply(transform_mode_angle)
		}
		
		// Release
		if (!mouse_left)
		{
			window_busy = ""
			view_control_edit = null
			view_control_matrix = null
			view_control_length = null
			view_control_move_distance = 0
			view_control_value = 0

			ds_map_clear(view_control_transform_target_map)
			view_control_transform_history_started = false
		}
	}
}
