/// surface_require(surface, width, height, [depth])
/// @arg surface
/// @arg width
/// @arg height
/// @arg [depth]

var surf, w, h, starttime, surfdepth;
surf = argument[0]
w = max(1, argument[1])
h = max(1, argument[2])

if (argument_count > 3)
	surfdepth = argument[3]
else
	surfdepth = false

starttime = current_time

if (surfdepth)
	surface_depth_disable(false)

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

if (surfdepth)
	surface_depth_disable(true)

render_surface_time += current_time - starttime

return surf
