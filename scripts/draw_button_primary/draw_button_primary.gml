/// draw_button_primary(name, x, y, width, script, [icon, [anchor, [disabled]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg script
/// @arg [icon
/// @arg [anchor
/// @arg [disabled]]]

var name, xx, yy, width, height, script, icon, anchor, disabled;
name = argument[0]
xx = argument[1]
yy = argument[2]
width = argument[3]
height = 28
script = argument[4]
icon = null
anchor = fa_left
disabled = false

if (argument_count > 5)
	icon = argument[5]
	
if (argument_count > 6)
	anchor = argument[6]

if (argument_count > 7)
	disabled = argument[7]

if (yy > content_y + content_height || yy + height < content_y)
	return 0

draw_set_font(font_button)

var textwidth, textx;
textwidth = string_width(text_get(name))

if (icon != null)
{
	height = 36
	
	// Icon + padding between
	textwidth += 32
}

// Add padding for dynamic width
if (width = null)
{
	// Icon, 8px left - 16px right
	if (icon != null)
	{
		textwidth += 24
		textx = 8
	}
	else // No icon, 16px left - 16px right
	{
		textwidth += 32
		textx = 16
	}
	
	width = textwidth
}
else
	textx = floor(width/2 - textwidth/2)

// Set anchor
if (anchor = fa_center)
	xx = floor(xx + (dw/2) - (width/2))
else if (anchor = fa_right)
	xx = xx + dw - width

textx += xx

var mouseon, mouseclick;
mouseon = app_mouse_box(xx, yy, width, height) && content_mouseon && !disabled
mouseclick = mouseon && mouse_left

if (mouseon)
	mouse_cursor = cr_handpoint

microani_set(name, script, mouseon, mouseclick, false)

// Draw button background
var buttoncolor, buttonalpha;
buttoncolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.PRESS]))
buttoncolor = merge_color(buttoncolor, c_accent_pressed, mcroani_arr[e_mcroani.PRESS])
buttonalpha = lerp(1, a_accent_hover, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.PRESS]))
buttonalpha = lerp(buttonalpha, a_accent_pressed, mcroani_arr[e_mcroani.PRESS])

buttoncolor = merge_color(buttoncolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
buttonalpha = lerp(buttonalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

draw_box(xx, yy, width, height, false, buttoncolor, buttonalpha)	

// Accent accent hover outline
draw_box_hover(xx, yy, width, height, mcroani_arr[e_mcroani.HOVER])

// Bevel shading
draw_box_bevel(xx, yy, width, height, 1)

// Adjust text color based on button color for contrast
var darkcolor, lightcolor, color, alpha;

if (color_get_lum(c_button_text) > color_get_lum(c_text_main))
{
	darkcolor = c_text_main
	lightcolor = c_button_text
}
else
{
	darkcolor = c_button_text
	lightcolor = c_text_main
}

color = (setting_accent < 9 ? c_button_text : (color_get_lum(c_accent) > 135 ? darkcolor : lightcolor))
alpha = (setting_accent < 9 ? a_button_text : (color_get_lum(c_accent) > 135 ? a_button_text : a_text_main))

// Transition text color for disabled state
color = merge_color(color, c_button_text, mcroani_arr[e_mcroani.DISABLED])
alpha = lerp(alpha, a_button_text, mcroani_arr[e_mcroani.DISABLED])

if (icon != null)
{
	draw_image(spr_icons, icon, textx + 10, yy + 18, 1, 1, color, 1)
	textx += 32
}

draw_label(text_get(name), textx, yy + height/2, fa_left, fa_middle, color, alpha)

microani_update(mouseon, mouseclick, false, disabled)

if (mouseon && mouse_left_released)
{
	if (script != null)
		script_execute(script)
		
	return true
}