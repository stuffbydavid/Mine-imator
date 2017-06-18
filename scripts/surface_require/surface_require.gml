/// surface_require(surface, width, height)
/// @arg surface
/// @arg width
/// @arg height

var surf, w, h, starttime;
surf = argument0
w = max(1, argument1)
h = max(1, argument2)

starttime = current_time

// First usage
if (surf < 0)
	surf = surface_create(w, h)
	
// Corrupted
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
