/// surface_require(surface, width, height, [depth, [hdr]])
/// @arg surface
/// @arg width
/// @arg height
/// @arg [depth
/// @arg [hdr]]

function surface_require(surf, w, h, depth = true, hdr = false)
{
	var format, starttime;
	w = max(1, w)
	h = max(1, h)
	
	// surface_rgba32float support not guaranteed in GM
	if (is_cpp())
		format = hdr ? surface_rgba32float : surface_rgba8unorm
	else 
		format = hdr ? surface_rgba16float : surface_rgba8unorm
	
	starttime = get_timer()
	
	// First usage
	if (surf < 0)
		surf = surface_create_ext2(w, h, format, depth)
	
	// Corrupted/remake for depth
	else if (!surface_exists(surf) || surface_get_width(surf) < 0) 
	{
		surface_free(surf)
		surf = surface_create_ext2(w, h, format, depth)
	}
	
	// Wrong size
	else if (surface_get_width(surf) != w || surface_get_height(surf) != h)
		surface_resize(surf, w, h)
	
	if (benchmark_mode)
		benchmark_surface_total_time += get_timer() - starttime
	
	return surf
}
