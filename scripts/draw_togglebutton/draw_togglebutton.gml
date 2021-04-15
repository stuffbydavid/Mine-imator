/// draw_togglebutton(name, x, y, [labels, [showcaption]])
/// @arg name
/// @arg x
/// @arg y
/// @arg [labels
/// @arg [showcaption]]
/// @desc Displays togglebutton options

var name, xx, yy, labels, showcaption;
var h, w, buttonx, buttonh, buttoncount, buttonsize, mouseon, script, scriptvalue, axis;
name = argument[0]
xx = argument[1]
yy = argument[2]
labels = true
showcaption = true

if (argument_count > 3)
	labels = argument[3]

if (argument_count > 4)
	showcaption = argument[4]

h = 32 + (label_height + 8)
w = dw

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
{
	togglebutton_reset()
	return 0
}

// Label
if (showcaption)
{
	draw_set_font(font_label)
	draw_label(string_limit(text_get(name), dw), xx, yy - 3, fa_left, fa_top, c_text_secondary, a_text_secondary)
	yy += (label_height + 8)
}

buttonx = xx
buttonh = 32

buttoncount = array_length_1d(togglebutton_name)
buttonsize = w/buttoncount
mouseon = false
script = null
scriptvalue = null
axis = X

// Draw frame
draw_box(xx, yy, w, buttonh, false, c_level_top, draw_get_alpha())
draw_outline(xx, yy, w, buttonh, 1, c_border, a_border, true)
for (var i = 0; i < buttoncount; i++)
{	
	if (i > 0)
		draw_box(buttonx, yy + 1, 1, buttonh - 2, false, c_border, a_border)
	
	buttonx += buttonsize
}
buttonx = xx

// Draw combo buttons
var boxwid;
for (var i = 0; i < buttoncount; i++)
{	
	boxwid = buttonsize
	
	if (i < (buttoncount - 1))
		boxwid += 1
	
	mouseon = false
	
	if (app_mouse_box(buttonx, yy, buttonsize, buttonh) && content_mouseon)
		mouseon = true
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name + togglebutton_name[i], null, mouseon, mouseon && mouse_left, togglebutton_active[i])
	
	// Draw base button
	var focus, backcolor, backalpha, linecolor, linealpha, contentcolor, contentalpha;
	focus = max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE])
	
	backcolor = merge_color(c_overlay, c_accent_overlay, focus)
	backalpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.HOVER])
	backalpha = lerp(backalpha, a_accent_overlay, focus)
	backalpha = lerp(backalpha, 0, mcroani_arr[e_mcroani.DISABLED])
	
	contentcolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
	contentcolor = merge_color(contentcolor, c_accent, focus)
	contentalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
	contentalpha = lerp(contentalpha, 1, focus)
	
	linecolor = merge_color(c_border, c_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	linecolor = merge_color(linecolor, c_accent, focus)
	linealpha = lerp(0, a_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	linealpha = lerp(linealpha, a_accent, focus)
	
	draw_box(buttonx, yy, boxwid, buttonh, false, backcolor, backalpha)
	
	var icon = togglebutton_icon[i];
	
	var buttonname, totalwidth, startx;
	draw_set_font(font_button)
	buttonname = string_limit((labels ? text_get(togglebutton_name[i]) : ""), boxwid - 16)
	totalwidth = (labels ? string_width(buttonname) : 0) + (icon = null ? 0 : 24 + 8)
	startx = floor(buttonx + (boxwid/2) - (totalwidth/2))
	
	if (buttonname = "" || !labels)
	{
		totalwidth = 24
		startx = floor(buttonx + (boxwid/2) - (totalwidth/2))
	}
	
	// Icon
	if (icon != null)
	{
		draw_image(spr_icons, icon, startx + 12, yy + (buttonh/2), 1, 1, contentcolor, contentalpha)
		startx += 24 + 8
	}
	
	// Text
	if (labels)
	{
		draw_set_font(font_button)
		draw_label(buttonname, startx, yy + (buttonh/2), fa_left, fa_middle, contentcolor, contentalpha)
	}
	
	// Outline
	draw_outline(buttonx, yy, boxwid, buttonh, 1, c_level_middle, max(focus, mcroani_arr[e_mcroani.HOVER]), true)
	draw_outline(buttonx, yy, boxwid, buttonh, 1, linecolor, linealpha, true)
	
	draw_box_hover(buttonx, yy, boxwid, buttonh, mcroani_arr[e_mcroani.PRESS])
	
	microani_update(mouseon && !mouse_left, mouseon && mouse_left, togglebutton_active[i])
	
	// Execute script with value
	if (mouseon && mouse_left_released)
	{
		if (togglebutton_script[i] != null)
		{
			script = togglebutton_script[i]
			scriptvalue = togglebutton_value[i]
			axis = togglebutton_axis[i]
		}
	}
	
	buttonx += buttonsize
}



buttonx = xx

// Repeat drawing for hover
/*
for (var i = 0; i < buttoncount; i++)
{
	mouseon = false
	
	if (app_mouse_box(buttonx, yy, buttonsize, buttonh) && content_mouseon)
		mouseon = true
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name + togglebutton_name[i], null, mouseon, mouseon && mouse_left, togglebutton_active[i])
	
	draw_box_hover(buttonx, yy, buttonsize, buttonh, mcroani_arr[e_mcroani.HOVER])
	buttonx += buttonsize
}
*/

// Execute script
if (script != null)
{
	axis_edit = axis
	
	if (scriptvalue != null)
		script_execute(script, scriptvalue)
	else
		script_execute(script)
	
	axis_edit = X
}

// Clear togglebutton options
togglebutton_reset()
	