/// @desc Saves picking IDs and detaches the extra target used by Quick rendering.

function render_place_end()
{
	if (!render_place)
		return 0
	
	// Copy compact ID list, if modified
	var view = render_place_view;
	if (view.surface_place_tl_list_id != render_place_tl_list_id)
	{
		view.surface_place_tl_list = array_copy_1d(render_place_tl_list)
		view.surface_place_tl_list_id = render_place_tl_list_id
	}
	
	// Exit for Standard/Realistic
	if (!view.surface_place_separate)
		return 0
	
	// Restore object blend states for target
	if (is_cpp())
		render_target_blend(1, true)
	
	// Remove MRT binding
	surface_reset_target()
	
	// Restore surface target and 3D projection
	surface_set_target(render_surface[0])
	render_set_projection(cam_from, cam_to, cam_up, cam_fov, render_ratio, cam_near, cam_far)
}
