/// shortcut_draw(shortcut)
/// @arg shortcut
/// @desc Draws shortcut at current dx/dy position and advances

var shortcut, mouse, yy, padding, imgpadding;
shortcut = argument0
yy = dy + (dh / 2)
padding = 10
imgpadding = 4

draw_set_font(font_label)

// Keyboard shortcut ("0")
if (shortcut[0] != null)
{
	var keyboardarray = string_split(text_control_name(shortcut[0]), " + ");
	for (var i = 0; i < array_length_1d(keyboardarray); i++)
	{
		keyboardarray[i] = string_replace(keyboardarray[i], " + ", "")
		var stringsize = string_width(keyboardarray[i]);
		
		draw_box(dx, yy - 8, stringsize + 12, 16, false, c_text_tertiary, a_text_tertiary)
		draw_box(dx + 2, yy - 6, stringsize + 8, 12, false, c_level_top, 1)
		
		draw_label(keyboardarray[i], dx + 6, yy, fa_left, fa_middle, c_text_tertiary, a_text_tertiary)
		
		dx += (stringsize + 12) + (i < (array_length_1d(keyboardarray) - 1) ? imgpadding : 0)
	}
	
	dx += (shortcut[1] = null ? padding : imgpadding)
}

// Mouse icon ("1")
if (shortcut[1] != null)
{
	switch (shortcut[1])
	{
		case e_mouse.CLICK_LEFT: mouse = icons.CLICK_LEFT; break;
		case e_mouse.CLICK_MIDDLE: mouse = icons.CLICK_MIDDLE; break;
		case e_mouse.CLICK_RIGHT: mouse = icons.CLICK_RIGHT; break;
		case e_mouse.DRAG_LEFT: mouse = icons.DRAG_LEFT; break;
		case e_mouse.DRAG_MIDDLE: mouse = icons.DRAG_MIDDLE; break;
		case e_mouse.DRAG_RIGHT: mouse = icons.DRAG_RIGHT; break;
		case e_mouse.SCROLL: mouse = icons.SCROLL; break;
		default: mouse = icons.HELP;
	}
	
	draw_image(spr_icons, mouse, dx + 10, yy, 1, 1, c_text_tertiary, a_text_tertiary)
	dx += 20 + padding
}

// Label ("2")
draw_set_font(font_value)
draw_label(shortcut[2], dx, yy, fa_left, fa_middle, c_text_secondary, a_text_secondary)
dx += string_width(shortcut[2]) + 36
