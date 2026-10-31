/// @arg filename

function texture_create_square(fn)
{
	var tex = texture_create(fn, true, false);
	if (!tex)
		return null
	
	var ww, hh;
	ww = texture_width(tex)
	hh = texture_height(tex)
	
	if (ww = hh)
	{
		sprite_set_texture_page(tex, true)
		return texture_page_add_res(tex)
	}
	
	var size, surf, newtex;
	size = max(ww, hh)
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext(bm_one, bm_src_alpha)
		draw_texture(tex, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	newtex = texture_surface(surf)
	
	surface_free(surf)
	texture_free(tex)
	
	return newtex
}
