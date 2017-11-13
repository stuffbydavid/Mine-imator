/// surface_get_alpha_array(surface)
/// @arg surface
/// @desc Returns an array with the alpha values of the given surface.

var surf, wid, hei, arr;
surf = argument0
wid = surface_get_width(surf)
hei = surface_get_height(surf)

buffer_current = buffer_create(wid * hei * 4, buffer_fixed, 4)
buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
for (var py = 0; py < hei; py++)
	for (var px = 0; px < wid; px++)
		arr[px, py] = buffer_read_alpha(px, py, wid)
	
buffer_delete(buffer_current)

return arr