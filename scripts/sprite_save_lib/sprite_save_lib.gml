/// sprite_save_lib(sprite, subimage, filename)
/// @arg sprite
/// @arg subimage
/// @arg filename

var spr, subimg, fn;
spr = argument0
subimg = argument1
fn = argument2

var surf = surface_create(sprite_get_width(spr), sprite_get_height(spr));
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
	draw_sprite(spr, subimg, 0, 0)
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()
surface_save_lib(surf, fn)
surface_free(surf)