/// texture_export(texture, filename)
/// @arg texture
/// @arg filename

var tex, fn, surf;
tex = argument0
fn = argument1

if (!tex)
	return 0

surf = surface_create(texture_width(tex), texture_height(tex))
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
	draw_texture(tex, 0, 0)
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()

surface_save_lib(surf, fn)

surface_free(surf)
