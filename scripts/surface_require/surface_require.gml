/// surface_require(surface, width, height, [depth, [free]])
/// @arg surface
/// @arg width
/// @arg height
/// @arg [depth
/// @arg [free]]

var surf, w, h, starttime, surfdepth, free;
surf = argument[0]
w = max(1, argument[1])
h = max(1, argument[2])

if (argument_count > 3)
	surfdepth = argument[3]
else
	surfdepth = true

if (argument_count > 4)
	free = argument[4]
else
	free = false

starttime = current_time

surface_depth_disable(!surfdepth)

// First usage
if (surf < 0)
	surf = surface_create(w, h)
	
// Corrupted/remake for depth
else if (!surface_exists(surf) || surface_get_width(surf) < 0 || free) 
{
	surface_free(surf)
	surf = surface_create(w, h)
}

// Wrong size
else if (surface_get_width(surf) != w || surface_get_height(surf) != h)
	surface_resize(surf, w, h)

surface_depth_disable(true)

render_surface_time += current_time - starttime

return surf
