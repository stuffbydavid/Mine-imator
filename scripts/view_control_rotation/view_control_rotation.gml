/// view_control_rotation(view)
/// @arg view

var view, len, xrot, yrot, zrot;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos) * 0.2 * 0.8

// Create matrices
with (tl_edit)
{
	// Start from the parent matrix (body part transforms included), restore the position and remove all scaling
	zrot = matrix_parent
	zrot[MATX] = matrix[MATX]
	zrot[MATY] = matrix[MATY]
	zrot[MATZ] = matrix[MATZ]
	matrix_remove_scale(zrot)
}

xrot = matrix_multiply(matrix_build(0, 0, 0, 0, -90, tl_edit.value[ZROT], 1, 1, 1), zrot)
yrot = matrix_multiply(matrix_build(0, 0, 0, tl_edit.value[XROT] + 90, 0, tl_edit.value[ZROT], 1, 1, 1), zrot)

// Draw each axis
view_control_rotation_axis(view, XROT, c_yellow, xrot, len)
view_control_rotation_axis(view, YROT, test(setting_z_is_up, c_blue, c_red), yrot, len)
view_control_rotation_axis(view, ZROT, test(setting_z_is_up, c_red, c_blue), zrot, len)

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= XROT && view_control_edit <= ZROT)
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot, snapval;
		
		// Find rotate amount
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * test(view_control_flip, -1, 1)
		view_control_value += rot
		
		// Snap
		snapval = frame_editor.rotation.snap_enabled * frame_editor.rotation.snap_size
		
		// Update
		axis_edit = view_control_edit
		tl_value_set_start(action_tl_frame_rot, true)
		tl_value_set(view_control_edit, snap(view_control_value, snapval) - tl_edit.value[view_control_edit], true)
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}
