function view_place(view)
{
	if (window_busy != place_busy || !content_mouseon)
		return 0

	place_content_mouseon = null

	if (view.surface_width <= 0 || view.surface_height <= 0)
		return 0

	var hit = view_raycast(view, mouse_x - content_x, mouse_y - content_y, true);
	place_view_tl = hit[e_raycast.OBJECT]
	place_view_pos = hit[e_raycast.POSITION]
	place_view_air = !hit[e_raycast.HIT]

	// GM build placement uses the origin without CPU ray casting
	if (!is_cpp() && place_build)
		place_view_pos = vec3(0)

	// Scenery placement snaps using the face in the source mesh's local axes
	place_view_normal = dir_get_vec3(hit[e_raycast.FACE])
}
