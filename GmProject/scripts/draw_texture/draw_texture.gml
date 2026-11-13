/// @arg texture
/// @arg x
/// @arg y
/// @arg [xscale]
/// @arg [yscale]
/// @arg [color]
/// @arg [alpha]

function draw_texture(tex, xx, yy, xsca = 1, ysca = 1, col = c_white, alpha = 1)
{
	draw_texture_start()
	draw_texture_part(tex, xx, yy, 0, 0, texture_width(tex), texture_height(tex), xsca, ysca, col, alpha)
	draw_texture_done()
}
