/// @arg sprite
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_image_box_cover(spr, xx, yy, w, h)
{
	var sw, sh, scale;
	
	if (!sprite_exists(spr))
		return 0
	
	sw = sprite_get_width(spr)
	sh = sprite_get_height(spr)
	
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
	
	draw_image(spr, 0, xx, yy, scale, scale)
}
