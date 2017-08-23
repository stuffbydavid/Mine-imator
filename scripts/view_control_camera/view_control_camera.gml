/// view_control_camera(view)
/// @arg view

var view, len, xyang, zang;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos_rotate) * 0.2 * 0.5

with (tl_edit)
{
	// Start from the parent matrix, set the position and remove all scaling
	xyang = matrix_parent
	xyang[MATX] = world_pos_rotate[X]
	xyang[MATY] = world_pos_rotate[Y]
	xyang[MATZ] = world_pos_rotate[Z]
	matrix_remove_scale(xyang)
}

zang = matrix_multiply(matrix_build(0, 0, 0, 90, 0, tl_edit.value[CAMROTATEXYANGLE] + 90, 1, 1, 1), xyang)

view_control_rotation_axis(view, CAMROTATEXYANGLE, c_aqua, xyang, len)
view_control_rotation_axis(view, CAMROTATEZANGLE, c_aqua, zang, len)
view_control_position_axis(view, CAMROTATEDISTANCE, c_aqua, tl_edit.world_pos_rotate, tl_edit.world_pos)

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && (view_control_edit = CAMROTATEXYANGLE || view_control_edit = CAMROTATEZANGLE))
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot;
		
		// Find rotate amount
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * test(view_control_flip, -1, 1)
		view_control_value += rot
		
		// Update
		axis_edit = view_control_edit
		
		if (view_control_edit = CAMROTATEXYANGLE)
			tl_value_set_start(action_tl_frame_camrotatexyangle, true)
		else
			tl_value_set_start(action_tl_frame_camrotatezangle, true)
		
		tl_value_set(view_control_edit, view_control_value - tl_edit.value[view_control_edit], true)
		
		if (frame_editor.camera.look_at_rotate)
		{
			if (view_control_edit = CAMROTATEXYANGLE)
				tl_value_set(ZROT, tl_edit.value[CAMROTATEXYANGLE], false)
			else
				tl_value_set(XROT, tl_edit.value[CAMROTATEZANGLE], false)
		}
		
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}

if (window_busy = "rendercontrol" && view_control_edit = CAMROTATEDISTANCE)
{
	mouse_cursor = cr_handpoint
	
	// Move
	var veclen = vec2_length(view_control_vec)
	if (veclen > 0 && !mouse_still)
	{
		var vecmouse, vecdot, dis, move;
		
		// Find move factor
		vecmouse = vec2(mouse_dx, mouse_dy)
		vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
		dis = point3D_distance(tl_edit.world_pos, tl_edit.world_pos_rotate)
		move = vec2_length(vecmouse) * (dis / veclen) * vecdot
		view_control_value += move
		
		// Update
		axis_edit = view_control_edit
		tl_value_set_start(action_tl_frame_camrotatedistance, true)
		tl_value_set(view_control_edit, view_control_value - tl_edit.value[view_control_edit], true)
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}
