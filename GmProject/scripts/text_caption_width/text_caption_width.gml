/// @arg keys...

function text_caption_width()
{
	var font = draw_get_font();
	draw_set_font(font_label)
	
	var wid = 0;
	for (var a = 0; a < argument_count; a++)
		if (text_exists(argument[a]))
			wid = max(wid, string_width(text_get(argument[a])) + 8)
		else
			wid = max(wid, string_width(argument[a]) + 8)
	
	draw_set_font(font)
	return wid
}
