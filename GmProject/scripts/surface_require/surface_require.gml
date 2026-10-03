/// @arg surface
/// @arg width
/// @arg height
/// @arg [depth]
/// @arg [format]

function surface_require(surf, w, h, depth = true, format = surface_rgba8unorm)
{
	var starttime;
	w = max(1, w)
	h = max(1, h)
	
	// surface_rgba32float support not guaranteed in GM
	if (format = surface_rgba32float)
		format = is_cpp() ? surface_rgba32float : surface_rgba16float
	
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
