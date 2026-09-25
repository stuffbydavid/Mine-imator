/// view_place(view, camera)
/// @arg view
/// @arg camera

function view_place(view, cam)
{
	if (window_busy != place_busy || !content_mouseon)
		return
	place_content_mouseon = null

	var surfaceid, surfacenormal, surfacedepth;
	surfaceid = view.surface_place_id
	surfacenormal = view.surface_place_normal
	surfacedepth = view.surface_place_depth_gm
	view.surface_place_id = surface_require(view.surface_place_id, content_width, content_height)
	view.surface_place_normal = surface_require(view.surface_place_normal, content_width, content_height, false)
	
	if (!is_cpp())
		view.surface_place_depth_gm = surface_require(view.surface_place_depth_gm, content_width, content_height, false)
		
	// Outdated or invalid surfaces
	if (view.surface_place_id != surfaceid || view.surface_place_normal != surfacenormal ||
		(!is_cpp() && view.surface_place_depth_gm != surfacedepth) ||
		view.surface_place_width != content_width || view.surface_place_height != content_height)
		view.update_place_surfaces = true
	
	view.surface_place_width = content_width
	view.surface_place_height = content_height

	// Update placement surfaces with placed object hidden
	if (view.update_place_surfaces)
	{
		render_start(null, null, view, content_width, content_height) // No camera to disable effects
		render_camera = cam
		render_update_camera()
		place_tl_render = false
		
		// Render timeline IDs and normals
		if (is_cpp())
			surface_clear_depth_cache(view.surface_place_id)
		surface_set_target_ext(0, view.surface_place_id)
		surface_set_target_ext(1, view.surface_place_normal)
		if (!is_cpp())
			surface_set_target_ext(2, view.surface_place_depth_gm)
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)
			draw_clear_alpha(c_black, 0)
			render_world_start()
			render_world(e_render_mode.PLACE)
			render_world_done()
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		render_done()
		view.update_place_surfaces = false
	}
	place_tl_render = true

	var mx, my, tx, ty, depthval, normalface, worldtransform, localpos;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	tx = mx / content_width
	ty = 1 - my / content_height
	
	// C++ path uses optimized depth lookup
	if (is_cpp())
		depthval = surface_get_depth(view.surface_place_id, mx, my)
	else
	{
		// GameMaker path uses packed depth value in color
		var packeddepth;
		packeddepth = surface_getpixel(view.surface_place_depth_gm, mx, my)
		packeddepth = color_get_red(packeddepth) / 255 + color_get_green(packeddepth) / (255 * 255) + color_get_blue(packeddepth) / (255 * 255 * 255)
		depthval = 1 - sqr(packeddepth)
	}
	
	// Calculate world hit position
	var maxdepth, clipspace, viewspace, inverseview;
	maxdepth = 0.99975
	clipspace = vec4(tx * 2 - 1, ty * 2 - 1, min(maxdepth, depthval) * 2 - 1, 1)
	viewspace = vec4_homogenize(vec4_mul_matrix(clipspace, matrix_inverse_ext(proj_matrix)))
	inverseview = matrix_inverse_ext(view_matrix)
	
	place_view_color = 0
	place_view_normal = vec3(0, 1, 0)
	place_view_pos = point3D_mul_matrix(viewspace, inverseview)
	place_view_ray = vec3_normalize(vec3_mul_matrix(viewspace, inverseview))
	
	// Retrieve color and normal
	if (depthval < maxdepth)
	{
		var normalpacked = surface_getpixel(view.surface_place_normal, mx, my);
		place_view_color = surface_getpixel(view.surface_place_id, mx, my)
		place_view_normal = vec3_normalize(vec3(
			color_get_red(normalpacked) / 255 * 2 - 1,
			color_get_green(normalpacked) / 255 * 2 - 1,
			color_get_blue(normalpacked) / 255 * 2 - 1
		))
		place_view_air = false
	}
	else
		place_view_air = true

	render_samples = -1
}
