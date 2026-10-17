/// @arg surface
/// @arg [render]
/// @arg [usepage]

function texture_surface(surf, render = true, usepage = true)
{
	var tex = sprite_create_from_surface(surf, 0, 0, surface_get_width(surf), surface_get_height(surf), false, false, 0, 0);
	
	if (!usepage)
	{
		sprite_set_texture_page(tex, false)
		return tex
	}
	
	return texture_page_add_res(tex, render)
}
