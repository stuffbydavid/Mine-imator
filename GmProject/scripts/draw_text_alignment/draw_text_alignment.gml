/// draw_text_alignment(prefix, caption, halign, valign, horizontal, vertical)

function draw_text_alignment(prefix, caption, halign, valign, horizontal, vertical)
{
	var olddx, olddw;
	olddx = dx
	olddw = dw
	
	if (caption != "")
	{
		dy += 20
		draw_label(text_get(caption) + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
		dy += 8
	}

	dw = floor(dw / 2 - 4)
	
	tab_control_togglebutton()
	togglebutton_add(prefix + "left", icons.TEXT_ALIGN_LEFT, "left", halign = "left", horizontal)
	togglebutton_add(prefix + "center", icons.TEXT_ALIGN_CENTER, "center", halign = "center", horizontal)
	togglebutton_add(prefix + "right", icons.TEXT_ALIGN_RIGHT, "right", halign = "right", horizontal)
	draw_togglebutton(prefix + "halign", dx, dy, false)
	
	dx += dw + 8
	
	togglebutton_add(prefix + "top", icons.ALIGN_TOP, "top", valign = "top", vertical)
	togglebutton_add(prefix + "center", icons.ALIGN_MIDDLE, "center", valign = "center", vertical)
	togglebutton_add(prefix + "bottom", icons.ALIGN_BOTTOM, "bottom", valign = "bottom", vertical)
	draw_togglebutton(prefix + "valign", dx, dy, false)
	
	tab_next()
	
	dx = olddx
	dw = olddw
}
