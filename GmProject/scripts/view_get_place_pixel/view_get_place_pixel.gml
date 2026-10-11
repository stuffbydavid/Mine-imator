/// @desc Reads linear viewport depth and packed object/face ID from the previous render

function view_get_place_pixel(view, xx, yy)
{
	if (!surface_exists(view.surface_place_id))
		return [ 1, 0, place_dir_none ]
	
	var pixel, packed, tl, face;
	pixel = surface_getpixel(view.surface_place_id, xx, yy)
	packed = round(pixel[1])
	tl = packed & ((1 << place_id_bits) - 1)
	face = (packed >> place_id_bits) & 7
	
	return [ pixel[0], tl, face ]
}
