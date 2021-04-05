/// draw_textfield_group(name, x, y, width, multiplier, min, max, snap, [showcaption, [stack, [axiscolor, [drag, [update_values]]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg snap
/// @arg [showcaption
/// @arg [stack
/// @arg [axiscolor
/// @arg [drag
/// @arg [update_values]]]]

var name, xx, yy, wid, mul, minval, maxval, snapval, showcaption, stack, axiscolor, drag, textfield_update;
var fieldx, fieldy, fieldwid, fieldupdate, hei, dragw, vertical, mouseon;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
mul = argument[4]
minval = argument[5]
maxval = argument[6]
snapval = argument[7]
showcaption = false
stack = true
axiscolor = false
drag = true
textfield_update = true

if (argument_count > 8)
	showcaption = argument[8]

if (argument_count > 9)
	stack = argument[9]

if (argument_count > 10)
	axiscolor = argument[10]

if (argument_count > 11)
	drag = argument[11]

if (argument_count > 12)
	textfield_update = argument[12]

vertical = (wid < 225) && stack
fieldx = xx
fieldy = yy
fieldwid = vertical ? wid : (wid/textfield_amount)
fieldupdate = null
hei = (vertical ? (24 * textfield_amount) : 24) + ((label_height + 8) * showcaption)

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
{
	textfield_group_reset()
	return 0
}

mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon

// Last textfield has 'active' animation, will need that for label color and border
microani_set(string(textfield_textbox[textfield_amount - 1]) + textfield_name[textfield_amount - 1], textfield_script[textfield_amount - 1], false, false, false, false, 1, false)

var active = current_mcroani.custom;
microani_set(name, null, mouseon || active, false, false)
microani_update(mouseon || active, false, false)

if (showcaption)
{
	draw_set_font(font_label)
	draw_label(string_limit(text_get(name), dw), xx, yy, fa_left, fa_top, c_text_secondary, a_text_secondary)
	yy += (label_height + 12)
}

hei = 24
fieldx = xx
fieldy = yy
dragw = 16

draw_box(xx, yy, wid, (vertical ? textfield_amount * hei : hei), false, c_level_top, draw_get_alpha())

// Draw field backgrounds
if (vertical)
	draw_outline(fieldx, fieldy, wid, textfield_amount * hei, 1, c_border, a_border, true)
else
	draw_outline(fieldx, fieldy, wid, hei, 1, c_border, a_border, true)

draw_set_font(font_label)
for (var i = 0; i < textfield_amount; i++)
{	
	if (i > 0)
	{
		if (vertical)
			draw_box(fieldx + 1, fieldy - 1, fieldwid - 2, 1, false, c_border, a_border)
		else
			draw_box(fieldx, fieldy + 1, 1, hei - 2, false, c_border, a_border)
	}
	
	if (vertical)
		fieldy += hei
	else
		fieldx += fieldwid
	
	// Get max dragging width from labels
	dragw = max(dragw, string_width(text_get(textfield_name[i])) + 16)
}

fieldx = xx
fieldy = yy

// Draw fields
var boxwid, boxhei, boxy, update, active;
active = false

for (var i = 0; i < textfield_amount; i++)
{
	axis_edit = textfield_axis[i]
	boxhei = hei
	boxwid = fieldwid
	boxy = fieldy
	
	if (i < (textfield_amount - 1) && !vertical)
		boxwid += 1
	
	if (i != 0 && vertical)
	{
		boxhei += 1
		boxy -= 1
	}
	
	mouseon = app_mouse_box(fieldx, boxy, boxwid, boxhei) && content_mouseon
	
	if (textfield_min != null)
	{
		minval = textfield_min[i]
		maxval = textfield_max[i]
	}
	
	context_menu_area(fieldx, boxy, boxwid, boxhei, "contextmenuvalue", textfield_value[i], e_context_type.NUMBER, textfield_script[i], textfield_default[i])
	
	microani_set(string(textfield_textbox[i]) + textfield_name[i], textfield_script[i], mouseon || window_focus = string(textfield_textbox[i]), false, (mouseon && mouse_left) || (window_focus = string(textfield_textbox[i])))
	
	// Draw base button
	var focus, linecolor, linealpha;
	focus = max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE])
	linecolor = merge_color(c_border, c_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	linecolor = merge_color(linecolor, c_accent, focus)
	linealpha = lerp(0, a_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	linealpha = lerp(linealpha, a_accent, focus)
	
	var col = c_text_secondary;
	var alpha = a_text_secondary;
	
	if (axiscolor)
	{
		if (i = 0)
			col = c_axisred
		else if (i = 1)
			col = c_axisgreen
		else
			col = c_axisblue
	
		alpha = 1
	}
	
	if (textfield_icon[i] = null)
		draw_label(text_get(textfield_name[i]), fieldx + 8, boxy + (boxhei/2), fa_left, fa_middle, col, alpha, font_label)
	else
		draw_image(spr_icons, textfield_icon[i], floor(fieldx + 14), boxy + (boxhei/2), 1, 1, c_text_secondary, a_text_secondary)
	
	// Outline
	draw_outline(fieldx, boxy, boxwid, boxhei, 1, c_level_middle, max(focus, mcroani_arr[e_mcroani.HOVER]), true)
	draw_outline(fieldx, boxy, boxwid, boxhei, 1, linecolor, linealpha, true)
	
	draw_box_hover(fieldx, boxy, boxwid, boxhei, mcroani_arr[e_mcroani.PRESS])
	
	active = (active || window_focus = string(textfield_textbox[i]))
	microani_update(mouseon, mouseon && mouse_left, window_focus = string(textfield_textbox[i]), false, active)
	
	// Textbox
	draw_set_font(font_digits)
	
	var update = textbox_draw(textfield_textbox[i], fieldx + dragw, boxy + (boxhei/2) - 7, boxwid - (8 + dragw), 18, true, true);
	
	// Textbox press
	if (app_mouse_box(fieldx + dragw, boxy, boxwid - (8 + dragw), boxhei) && content_mouseon && window_focus != string(textfield_textbox[i]))
	{
		if (mouse_left_released)
		{
			window_focus = string(textfield_textbox[i])
			window_busy = ""
		}
	}
	
	// Drag
	if (app_mouse_box(fieldx + 8, boxy, dragw, boxhei) && content_mouseon && window_focus != string(textfield_textbox[i]) && drag)
	{
		mouse_cursor = cr_size_we
	
		if (mouse_left_pressed)
			window_busy = textfield_name[i] + "press"
	}
	
	// Mouse pressed
	if (window_busy = textfield_name[i] + "press")
	{
		mouse_cursor = cr_size_we
	
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
		else if (mouse_dx != 0)
		{
			dragger_drag_value = textfield_value[i]
			window_busy = textfield_name[i] + "drag" // Start dragging
		}
	}
	
	// Is dragging
	if (window_busy = textfield_name[i] + "drag")
	{ 
		mouse_cursor = cr_none
		dragger_drag_value += (mouse_x - mouse_click_x) * (textfield_mul[i] = null ? mul : textfield_mul[i]) * dragger_multiplier
		window_mouse_set(mouse_click_x, mouse_click_y)
		
		var d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - textfield_value[i];
		
		if (d <> 0 && textfield_script[i] != null && textfield_update)
			script_execute(textfield_script[i], d, true)
		else
		{
			textfield_textbox[i].text = string_decimals(textfield_value[i] + d)
			fieldupdate = textfield_textbox[i]
		}
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
			
			script_execute(textfield_script[i], d, true)
		}
	}
	
	// Textbox input update
	if (update)
	{
		if (textfield_script[i] != null)
			script_execute(textfield_script[i], clamp(string_get_real(textfield_textbox[i].text, textfield_default[i]), minval, maxval), false)
		else
			fieldupdate = textfield_textbox[i]
	}
	
	// Idle update
	if (window_busy != textfield_name[i] + "press" && window_focus != string(textfield_textbox[i]) && !fieldupdate)
		textfield_textbox[i].text = string_decimals(textfield_value[i])
	
	if (vertical)
		fieldy += hei
	else
		fieldx += fieldwid
}

textfield_group_reset()

return fieldupdate