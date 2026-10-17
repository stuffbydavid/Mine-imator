/// @arg sprite
/// @arg subimage
/// @arg x
/// @arg y
/// @arg [xscale]
/// @arg [yscale]
/// @arg [color]
/// @arg [alpha]
/// @arg [rotation]

function draw_image(spr, img, xx, yy, xsca = 1, ysca = 1, col = c_white, alpha = 1, rot = 0)
{
	draw_sprite_ext(spr, img, xx, yy, xsca, ysca, rot, col, alpha * draw_get_alpha())
}
