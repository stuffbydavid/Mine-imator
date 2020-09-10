/// draw_button_secondary(name, x, y, width, height, script, [icon])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg script
/// @arg [icon]

var name, xx, yy, width, height, script, icon;
name = argument[0]
xx = argument[1]
yy = argument[2]
width = argument[3]
height = 28
script = argument[4]
icon = null

if (argument_count > 5)
	icon = argument[5]

draw_set_font(font_button)

var textwidth = string_width(text_get(name)) + 28;
width = textwidth

if (icon != null)
{
	width += 28
	height = 36
}

var mouseon, mouseclick;
mouseon = app_mouse_box(xx, yy, width, height) && content_mouseon
mouseclick = mouseon && mouse_left

if (mouseon)
	mouse_cursor = cr_handpoint

microani_set(name, script, mouseon, mouseclick, false)

// Accent hover outline
draw_box_hover(xx, yy, width, height, mcroani_arr[e_mcroani.HOVER])

// Box
var bordercolor, borderalpha, labelcolor, labelalpha;
bordercolor = merge_color(c_border, c_accent, mcroani_arr[e_mcroani.PRESS])
borderalpha = lerp(a_border, 1, mcroani_arr[e_mcroani.PRESS])

labelcolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER])
labelcolor = merge_color(labelcolor, c_accent_pressed, mcroani_arr[e_mcroani.PRESS])
labelalpha = lerp(1, a_accent_hover, mcroani_arr[e_mcroani.HOVER])
labelalpha = lerp(labelalpha, a_accent_pressed, mcroani_arr[e_mcroani.PRESS])

draw_box(xx, yy, width, height, false, c_accent_overlay, a_accent_overlay * mcroani_arr[e_mcroani.PRESS])
draw_outline(xx + 1, yy + 1, width - 2, height - 2, 1, bordercolor, borderalpha)

var textx = xx;
if (icon != null)
	textx += 28

draw_label(text_get(name), textx + textwidth/2, yy + height/2, fa_center, fa_middle, labelcolor, labelalpha)

if (icon != null)
	draw_image(spr_icons, icon, xx + 18, yy + 18, 1, 1, labelcolor, labelalpha)

microani_update(mouseon, mouseclick, false)

if (mouseon && mouse_left_released)
{
	if (script != null)
		script_execute(script)
	
	return true
}