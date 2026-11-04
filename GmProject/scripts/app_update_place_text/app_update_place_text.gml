/// @desc Keep the bottom of text one line above the placement level.

function app_update_place_text()
{
	var str, font, res, oldfont, hei, bottom, sca, valign;
	str = place_tl.value[e_value.TEXT]
	if (string_char_at(str, string_length(str)) = "\n")
		str += " "

	font = place_tl.has_temp ? place_tl.value[e_value.TEXT_FONT] : null
	if (font = null)
		font = place_tl.temp.text_font
	
	res = res_eval(font)
	oldfont = draw_get_font()
	
	draw_set_font(place_tl.temp.text_aa ? res.font : res.font_no_aa)
	hei = string_height_ext(str, string_height(" ") - 2, -1) + 4
	draw_set_font(oldfont)

	valign = place_tl.has_temp && !place_tl.value[e_value.TEXT_CUSTOM_ALIGNMENT] ? place_tl.temp.text_valign : place_tl.value[e_value.TEXT_VALIGN]
	switch (valign)
	{
		case "top":		bottom = -hei + 3; break
		case "bottom":	bottom = 0; break
		default:		bottom = -hei / 2 + 0.5; break
	}
	sca = (res.font_minecraft ? 1 : 8 / 48) * place_sca[Z]
	place_pos[Z] += block_half_size - min(bottom * sca, (bottom + hei) * sca)
}
