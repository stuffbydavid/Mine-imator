/// surface_require(surface, width, height, [depth, [hdr]])
/// @arg surface
/// @arg width
/// @arg height
/// @arg [depth
/// @arg [hdr]]

function surface_require(surf, w, h, depth = true, surfformat = e_surface_format.rgba8unorm)
{
	var format, starttime;
	w = max(1, w)
	h = max(1, h)
	
	// surface_rgba32float support not guaranteed in GM
	if (surfformat == e_surface_format.rgba32float)
		format = is_cpp() ? surface_rgba32float : surface_rgba16float
	else if (surfformat == e_surface_format.r32float)
		format = surface_r32float
	else if (surfformat = e_surface_format.r8unorm)
		format = surface_r8unorm
	else if (surfformat = e_surface_format.r16float)
		format = surface_r16float
	else
		format = surface_rgba8unorm
	
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
