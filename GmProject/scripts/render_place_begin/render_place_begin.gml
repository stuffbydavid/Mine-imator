/// @desc Records viewport picking data from the color or G-buffer pass.
/// @arg [depthsurface]

function render_place_begin(depthsurf = null)
{
	if (!render_place)
		return 0
	
	var view = render_place_view;
	
	// Quick mode uses a separate surface for depth+ID+face storage
	if (renderer_current = e_renderer.QUICK)
	{
		surface_set_target_ext(1, view.surface_place_id)
		
		// Disable object blend mode settings for surface output
		if (is_cpp())
			render_set_target_blend(1, false)
		
		view.surface_place_separate = true
	}
	
	else // Standard and Realistic reuse the float depth surface from the COLOR pass
	{
		// Free previous Quick mode surface
		if (view.surface_place_separate && surface_exists(view.surface_place_id))
			surface_free(view.surface_place_id)
		
		view.surface_place_id = depthsurf
		view.surface_place_separate = false
	}
	
	view.surface_place_depth_near = depth_near
	view.surface_place_depth_far = depth_far
	view.surface_place_proj_matrix = matrix_multiply(proj_matrix, aa_matrix)
	view.surface_place_view_matrix = array_copy_1d(view_matrix)
	
	// Rebuild compact ID list
	if (render_place_tl_list = null)
		render_place_tl_list_update()
}
