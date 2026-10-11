function view_place(view)
{
	if (window_busy != place_busy || !content_mouseon)
		return 0
	
	place_content_mouseon = null

	if (!surface_exists(view.surface_place_id))
	{
		view_changed(view)
		return 0
	}
	
	var mx, my, tx, ty, data, depthval, tl, face;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	tx = mx / content_width
	ty = 1 - my / content_height
	
	// Get depth, object id and face index at mouse from the previous render
	data = view_get_place_pixel(view, mx, my)
	depthval = data[0]
	tl = data[1]
	if (tl > 0 && (tl >= array_length(view.surface_place_tl_list) || !instance_exists(view.surface_place_tl_list[tl])))
		return 0
	
	face = data[2]
	if (face = place_dir_none)
		depthval = 1
	
	// Calculate world hit position
	var maxdepth, clipspace, viewspace, inverseview;
	maxdepth = 0.99975
	clipspace = vec4(tx * 2 - 1, ty * 2 - 1, depthval >= 1 ? maxdepth * 2 - 1 : 0, 1)
	viewspace = vec4_mul_matrix(clipspace, matrix_inverse_ext(view.surface_place_proj_matrix))
	if (depthval < 1)
		viewspace = vec3_mul(viewspace, lerp(view.surface_place_depth_near, view.surface_place_depth_far, depthval) / viewspace[Z])
	else
		viewspace = vec4_homogenize(viewspace)
	inverseview = matrix_inverse_ext(view.surface_place_view_matrix)
	
	place_view_tl = 0
	place_view_normal = vec3(0, 1, 0)
	place_view_pos = point3D_mul_matrix(viewspace, inverseview)
	place_view_ray = vec3_normalize(vec3_mul_matrix(viewspace, inverseview))
	
	// Retrieve color and normal
	if (depthval < 1)
	{
		if (tl < array_length(view.surface_place_tl_list))
			place_view_tl = view.surface_place_tl_list[tl]
		
		switch (face)
		{
			case e_dir.EAST:	place_view_normal = vec3(1, 0, 0); break
			case e_dir.WEST:	place_view_normal = vec3(-1, 0, 0); break
			case e_dir.SOUTH:	place_view_normal = vec3(0, 1, 0); break
			case e_dir.NORTH:	place_view_normal = vec3(0, -1, 0); break
			case e_dir.UP:		place_view_normal = vec3(0, 0, 1); break
			case e_dir.DOWN:	place_view_normal = vec3(0, 0, -1); break
		}
		
		place_view_air = false
	}
	else
		place_view_air = true
}
