/// draw_searchbox(name, x, y, width, textbox, [stretch])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg textbox
/// @arg [stretch]
/// @desc Draws a search box and returns whether its text changed

function draw_searchbox(name, xx, yy, wid, textbox, stretch = false)
{
	var searchwid, clearx, changed;
	searchwid = wid
	changed = false

	if (textbox.text != "")
	{
		clearx = xx - 28
		if (stretch)
		{
			clearx = xx + wid - 24
			searchwid -= 28
		}

		if (draw_button_icon(name + "clear", clearx, yy, 24, 24, false, icons.CLOSE_SMALL, null, false, "tooltipclearsearch"))
		{
			textbox.text = ""
			changed = true
		}
	}

	if (draw_textfield(name, xx, yy, searchwid, 24, textbox, null, text_get("listsearch"), "none"))
		changed = true

	return changed
}
