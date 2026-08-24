/// texture_create_square(filename)
/// @arg filename

function texture_create_square(fn)
{
	var tex, ww, hh;
	tex = texture_create(fn)
	ww = texture_width(tex)
	hh = texture_height(tex)
	
	if (ww = hh)
		return tex
	
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
