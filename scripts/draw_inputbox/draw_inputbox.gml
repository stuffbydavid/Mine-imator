/// draw_inputbox(name, x, y, width, height, placeholder, textbox, script, [disabled, [error, [font, [center]]]])
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
/// @arg [center]]]]

var inputname, xx, yy, w, h, placeholder, tbx, script, disabled, err, capwid, padding, font, center;
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
center = false

if (argument_count > 8)
	disabled = argument[8]

if (argument_count > 9)
	err = argument[9]

if (argument_count > 10)
	font = argument[10]

if (argument_count > 11)
	center = argument[11]

capwid = string_width(text_get(inputname))
padding = 3

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

var mouseon;
mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && (window_busy = "" || window_busy = string(tbx) + "click") && !disabled

microani_set(string(tbx) + inputname, script, mouseon || window_focus = string(tbx), false, (mouseon && mouse_left) || (window_focus = string(tbx)))

// Field background
var bordercolor, borderalpha;
bordercolor = merge_color(c_border, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
borderalpha = lerp(a_border, a_text_secondary, mcroani_arr[e_mcroani.HOVER])
bordercolor = merge_color(bordercolor, c_accent, max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE]))
borderalpha = lerp(borderalpha, a_accent, max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE]))
bordercolor = merge_color(bordercolor, c_border, mcroani_arr[e_mcroani.DISABLED])
borderalpha = lerp(borderalpha, a_border, mcroani_arr[e_mcroani.DISABLED])

if (err)
{
	bordercolor = c_error
	borderalpha = 1
}

draw_outline(xx + 1, yy + 1, w - 2, h - 2, 1, bordercolor, borderalpha)

// Error icon
if (err)
{
	draw_image(spr_icons, icons.ALERT, xx + w - 14, yy + h - 14, 1, 1, c_error, 1)
	w -= 28
}

// Search icon
if (string_contains(inputname, "search"))
{
	draw_image(spr_icons, icons.SEARCH, xx + w - 14, yy + h - 14, 1, 1, bordercolor, borderalpha)
	w -= 28
}

// Textbox
draw_set_font(font)

var textx, texty;
textx = (center ? xx + w/2 : xx + 10)
texty = (center ? yy + h/2 : yy + 5)

if (disabled)
{
	draw_label(string_limit(tbx.text, w - padding * 2), textx, texty, center ? fa_center : fa_left, center ? fa_bottom : fa_top, c_text_tertiary, a_text_tertiary)
	update = false
}

// Placeholder label
if (tbx.text = "" && placeholder != "")
    draw_label(string_limit(placeholder, w - padding * 2), textx, texty, center ? fa_center : fa_left, center ? fa_center : fa_top, c_text_tertiary, a_text_tertiary)

if (!disabled)
{
	if (center && (tbx.text != ""))
	{
		var textwid = min(w, string_width(tbx.text));
		update = textbox_draw(tbx, xx + w/2 - textwid/2, yy + 5, textwid, h - 9, true) // ,false)
	}
	else
		update = textbox_draw(tbx, xx + 10, yy + 5, w - 20, h - 9, true) // ,false)
}

// Textbox context menu
if (window_focus = string(tbx))
	context_menu_area(xx, yy, w, h, "contextmenutextbox", tbx, e_context_type.NONE, null, null)

// Disabled overlay
draw_box(xx, yy, w, h, false, c_overlay, a_overlay * mcroani_arr[e_mcroani.DISABLED])

if (mouseon && mouse_left_pressed && (window_focus != string(tbx)))
{
	window_focus = string(tbx)
	app_mouse_clear()
}

if (update && (script != null))
    script_execute(script, tbx.text)

// Input boxes don't use a holding animation, but need a warning animation
microani_update(mouseon || window_focus = string(tbx), false, window_focus = string(tbx), disabled)

return update