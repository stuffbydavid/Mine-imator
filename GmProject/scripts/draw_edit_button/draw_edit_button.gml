/// draw_edit_button(name, x, y, active, script, value, [tip, [disabled]])
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script
/// @arg value
/// @arg [tip
/// @arg [disabled]]

function draw_edit_button(name, xx, yy, active, script, value, tip = "", disabled = false)
{
	var text, w, h;
	text = text_get(name)
	w = dw
	h = ui_small_height

	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
		return 0

	// Label
	draw_set_font(font_label)
	draw_label(string_limit(text, w - 32), xx, yy + (h/2), fa_left, fa_middle, disabled ? c_text_tertiary : c_text_secondary, disabled ? a_text_tertiary : a_text_secondary)
	draw_help_circle(tip, xx + string_width(text) + 4, yy + (h/2) - 10, disabled)

	// Edit button
	if (draw_button_icon(name + "edit", xx + w - 24, yy + (h/2) - 12, 24, 24, active, icons.PENCIL, null, disabled))
	{
		if (script != null)
			script_execute(script, value)

		return true
	}

	return false
}
