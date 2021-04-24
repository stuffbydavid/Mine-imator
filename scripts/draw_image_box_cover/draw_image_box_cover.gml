/// draw_image_box_cover(sprite, x, y, width, height)
/// @arg sprite
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_image_box_cover(sprite, xx, yy, w, h)
{
	var sw, sh, scale;
	
	if (!sprite_exists(sprite))
		return 0
	
	sw = sprite_get_width(sprite)
	sh = sprite_get_height(sprite)
	
	if (sw / sh < w / h)
	{
		scale = w / sw
		yy += (h - scale * sh) / 2
		h = sh * scale
	}
	else
	{
		scale = h / sh
		xx += (w - scale * sw) / 2
		w = sw * scale
	}
	
	xx = floor(xx)
	yy = floor(yy)
	w = ceil(w)
	h = ceil(h)
	
	draw_image(sprite, 0, xx, yy, scale, scale)
}
