/// draw_inputbox(name, x, y, width, height, placeholder, textbox, script, [disabled, [error, [font, [type, [alpha]]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg placeholder
/// @arg textbox
/// @arg script
/// @arg [disabled
/// @arg [error
/// @arg [font
/// @arg [type
/// @arg [alpha]]]]]

function draw_inputbox()
{
	var inputname, xx, yy, w, h, placeholder, tbx, script, disabled, err, capwid, padding, font, type, alpha, focused;
	var update;
	
	inputname = argument[0]
	xx = argument[1]
	yy = argument[2]
	w = argument[3]
	h = argument[4]
	placeholder = argument[5]
	tbx = argument[6]
	script = argument[7]
	disabled = false
	err = false
	font = font_value
	type = e_inputbox.LEFT
	alpha = 1
	focused = (window_focus = string(tbx))
	
	if (argument_count > 8)
		disabled = argument[8]
	
	if (argument_count > 9)
		err = argument[9]
	
	if (argument_count > 10)
		font = argument[10]
	
	if (argument_count > 11)
		type = argument[11]
	
	if (argument_count > 12)
		alpha = argument[12]
	
	capwid = string_width(text_get(inputname))
	padding = (h - 22) / 2
	
	if (textbox_jump)
		ds_list_add(textbox_list, [tbx, content_tab, yy, content_y, content_height])
	
	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
		return 0
	
	var mouseon;
	mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && (window_busy = "" || window_busy = string(tbx) + "click") && !disabled
	
	microani_set(string(tbx) + inputname, script, mouseon || window_focus = string(tbx), false, (mouseon && mouse_left) || (window_focus = string(tbx)))
	
	// Field background
	var bordercolor, borderalpha;
	bordercolor = merge_color(c_border, c_text_secondary, microani_arr[e_microani.HOVER])
	bordercolor = merge_color(bordercolor, c_accent, max(microani_arr[e_microani.PRESS], microani_arr[e_microani.ACTIVE]))
	bordercolor = merge_color(bordercolor, c_border, microani_arr[e_microani.DISABLED])
	borderalpha = lerp(a_border, a_text_secondary, microani_arr[e_microani.HOVER])
	borderalpha = lerp(borderalpha, a_accent, max(microani_arr[e_microani.PRESS], microani_arr[e_microani.ACTIVE]))
	borderalpha = lerp(borderalpha, a_border, microani_arr[e_microani.DISABLED]) * alpha
	
	if (err)
	{
		bordercolor = c_error
		borderalpha = 1 * alpha
	}
	
	draw_box(xx, yy, w, h, false, c_level_top, alpha * draw_get_alpha())
	draw_outline(xx, yy, w, h, 1, bordercolor, borderalpha, true)
	draw_box_hover(xx, yy, w, h, microani_arr[e_microani.PRESS])
	
	// Error icon
	if (err)
	{
		draw_image(spr_icons, icons.WARNING_TRIANGLE, xx + w - 14, yy + (h/2), 1, 1, c_error, 1)
		w -= 28
	}
	
	// Search icon
	if (string_contains(inputname, "search"))
	{
		draw_image(spr_icons, icons.SEARCH, xx + w - 14, yy + (h/2), 1, 1, bordercolor, borderalpha)
		w -= 28
	}
	
	// Textbox
	draw_set_font(font)
	
	var tbxh, placeholderx, textx, texty, textvalign, texthalign;
	tbxh = max(string_height(" "), h - 9)
	
	if (type = e_inputbox.LEFT || type = e_inputbox.RIGHT)
	{
		textx = xx + 8
		texty = yy + floor(h/2) - ceil(tbxh/2)
		texthalign = fa_left
		textvalign = fa_top
		placeholderx = textx
		
		if (type = e_inputbox.RIGHT)
		{
			placeholderx = xx + w - 8
			texthalign = fa_right
		}
	}
	else
	{
		textx = xx + w/2
		texty = yy + 38
		texthalign = fa_center
		textvalign = fa_bottom
		
		placeholderx = textx
	}
	
	if (font = font_digits && h >= 24)
		texty += 1
	
	if (disabled)
	{
		draw_label(string_limit(tbx.text + tbx.suffix, w - padding * 2), placeholderx, texty, texthalign, textvalign, c_text_tertiary, a_text_tertiary)
		update = false
	}
	
	// Placeholder label
	if (tbx.text = "" && placeholder != "")
	{
		var suffixwid = string_width(tbx.suffix);
		draw_label(string_limit(placeholder, (w - suffixwid) - padding * 2), placeholderx - suffixwid, texty, texthalign, textvalign, c_text_tertiary, a_text_tertiary)
	}
	
	if (!disabled)
	{
		if (type = e_inputbox.BIG)
		{
			var textwid = min(w, string_width(tbx.text + tbx.suffix));
			update = textbox_draw(tbx, xx + w/2 - textwid/2, yy + 5, textwid, h - 9)
		}
		else
			update = textbox_draw(tbx, textx, texty, w - 16, tbxh, true, type = e_inputbox.RIGHT)
	}
	
	if (mouseon)
		mouse_cursor = cr_beam
	
	// Textbox context menu
	if (window_focus = string(tbx))
		context_menu_area(xx, yy, w, h, "contextmenutextbox", tbx, e_context_type.NONE, null, null)
	
	// Disabled overlay
	draw_box(xx, yy, w, h, false, c_overlay, a_overlay * microani_arr[e_microani.DISABLED])
	
	if (mouseon && mouse_left_released && (window_focus != string(tbx)))
	{
		window_focus = string(tbx)
		app_mouse_clear()
	}
	
	if (update && (script != null))
		script_execute(script, tbx.text)
	
	// Input boxes don't use a holding animation, but need a warning animation
	microani_update(mouseon || window_focus = string(tbx), (mouseon && mouse_left) && window_focus != string(tbx), window_focus = string(tbx), disabled)
	
	return update
}
