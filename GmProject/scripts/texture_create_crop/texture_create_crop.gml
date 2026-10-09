/// @desc Create a fixed-size texture.
/// @arg texture
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [usepage]
/// @arg [render]

function texture_create_crop(tex, xx, yy, wid, hei, usepage = true, render = true)
{
	var ntex, surf;
	xx = -xx
	yy = -yy
	
	surf = surface_create(wid, hei)
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext(bm_one, bm_src_alpha)
		draw_texture(tex, xx, yy)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	ntex = texture_surface(surf, render, usepage)
	surface_free(surf)
	
	return ntex
}
