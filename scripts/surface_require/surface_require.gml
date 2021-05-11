/// surface_require(surface, width, height)
/// @arg surface
/// @arg width
/// @arg height

function surface_require(surf, w, h)
{
	var starttime;
	w = max(1, w)
	h = max(1, h)
	
	starttime = current_time
	
	// First usage
	if (surf < 0)
		surf = surface_create(w, h)
	
	// Corrupted/remake for depth
	else if (!surface_exists(surf) || surface_get_width(surf) < 0) 
	{
		surface_free(surf)
		surf = surface_create(w, h)
	}
	
	// Wrong size
	else if (surface_get_width(surf) != w || surface_get_height(surf) != h)
		surface_resize(surf, w, h)
	
	render_surface_time += current_time - starttime
	
	return surf
}
