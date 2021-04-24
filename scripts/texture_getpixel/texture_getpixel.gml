/// texture_getpixel(texture, x, y)
/// @arg texture
/// @arg x
/// @arg y
/// @desc Check the color of a pixel in the texture.

function texture_getpixel(tex, xx, yy)
{
	var surf, col;
	surf = surface_create(texture_width(tex), texture_height(tex))
	surface_set_target(surf)
	{
		draw_texture(tex, 0, 0)
	}
	surface_reset_target()
	
	col = surface_getpixel(surf, xx, yy)
	surface_free(surf)
	
	return col
}
