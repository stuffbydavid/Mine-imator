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
	
	var mx, my, tx, ty, data, depthval, tl, face, pixelstate, depthnear, depthfar, projmatrix, viewmatrix, tllist;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	tx = mx / content_width
	ty = 1 - my / content_height
	
	// Get depth, object id and face index at mouse from the previous render
	data = view_get_place_pixel(view, mx, my)
	if (array_length(data) = 0)
		return 0
	
	depthval = data[0]
	tl = data[1]
	pixelstate = null
	
	depthnear = view.surface_place_depth_near
	depthfar = view.surface_place_depth_far
	projmatrix = view.surface_place_proj_matrix
	viewmatrix = view.surface_place_view_matrix
	tllist = view.surface_place_tl_list
	
	// Get camera state of pixel readback to reconstruct an accurate world hit
	if (array_length(data) > 3)
	{
		pixelstate = data[3]
		depthnear = pixelstate[1]
		depthfar = pixelstate[2]
		projmatrix = pixelstate[3]
		viewmatrix = pixelstate[4]
		tllist = pixelstate[5]
		
		// Set position
		var sx, sy, sw, sh;
		sx = pixelstate[6]
		sy = pixelstate[7]
		sw = pixelstate[8]
		sh = pixelstate[9]
		
		tx = sx / sw
		ty = 1 - sy / sh
	}
	
	// Invalid object
	if (tl > 0 && (tl >= array_length(tllist) || !instance_exists(tllist[tl])))
		return 0
	
	face = data[2]
	if (face = place_dir_none)
		depthval = 1
	
	// Calculate world hit position
	var maxdepth, clipspace, viewspace, inverseview;
	maxdepth = 0.99975
	clipspace = vec4(tx * 2 - 1, ty * 2 - 1, depthval >= 1 ? maxdepth * 2 - 1 : 0, 1)
	viewspace = vec4_mul_matrix(clipspace, matrix_inverse_ext(projmatrix))
	if (depthval < 1)
		viewspace = vec3_mul(viewspace, lerp(depthnear, depthfar, depthval) / viewspace[Z])
	else
		viewspace = vec4_homogenize(viewspace)
	inverseview = matrix_inverse_ext(viewmatrix)
	
	place_view_tl = 0
	place_view_normal = vec3(0, 1, 0)
	place_view_pos = point3D_mul_matrix(viewspace, inverseview)
	place_view_ray = vec3_normalize(vec3_mul_matrix(viewspace, inverseview))
	
	// Retrieve color and normal
	if (depthval < 1)
	{
		if (tl < array_length(tllist))
			place_view_tl = tllist[tl]
		
		place_view_normal = dir_get_vec3(face)
		place_view_air = false
	}
	else
		place_view_air = true
}
