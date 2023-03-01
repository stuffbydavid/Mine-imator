/// texture_create_crop(texture, x, y, width, height)
/// @arg texture
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @desc Create a fixed-size texture.

function texture_create_crop(tex, xx, yy, wid, hei)
{
	var ntex, surf;
	xx = -xx
	yy = -yy
	
	surf = surface_create(wid, hei)
	surface_set_target(surf)
	{
		draw_clear_alpha(c_white, 0)
		draw_texture(tex, xx, yy)
	}
	surface_reset_target()
	ntex = texture_surface(surf)
	surface_free(surf)
	
	return ntex
}
