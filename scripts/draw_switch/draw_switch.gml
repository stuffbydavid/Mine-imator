/// draw_switch(name, x, y, active, script, [tip, [disabled]])
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script
/// @arg [tip
/// @arg [disabled]]

var name, xx, yy, active, script, tip, disabled;
var switchx, switchy, w, h, mouseon, pressed, thumbgoal;
name = text_get(argument[0])
xx = argument[1]
yy = argument[2]
active = argument[3]
script = argument[4]
tip = ""
disabled = false

if (argument_count > 5)
	tip = argument[5]

if (argument_count > 6)
	disabled = argument[6]

w = dw
h = 24
switchx = (xx + dw - 22)
switchy = (yy + (h/2) - 7)

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

// Mouse
var mouseon, mouseclick;
mouseon = app_mouse_box(switchx, switchy, 24, 16) && content_mouseon && !disabled
mouseclick = mouseon && mouse_left

pressed = false

if (mouseon)
{
    if (mouse_left || mouse_left_released)
        pressed = true
	
    mouse_cursor = cr_handpoint
}

if (pressed)
	thumbgoal = 0.5
else if (active)
	thumbgoal = 1
else
	thumbgoal = 0

// Set micro animation before drawing
microani_set(argument[0], script, mouseon, mouseclick, active, disabled, 1, 0, thumbgoal)

// Draw background
var offcolor, offalpha, oncolor, onalpha, color, alpha;
offcolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
offcolor = merge_color(offcolor, c_accent, mcroani_arr[e_mcroani.PRESS])
offalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
offalpha = lerp(offalpha, a_accent, mcroani_arr[e_mcroani.PRESS])

oncolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER])
oncolor = merge_color(oncolor, c_accent_pressed, mcroani_arr[e_mcroani.PRESS])
onalpha = lerp(a_accent, a_accent_hover, mcroani_arr[e_mcroani.HOVER])
onalpha = lerp(onalpha, a_accent_pressed, mcroani_arr[e_mcroani.PRESS])

color = merge_color(offcolor, oncolor, mcroani_arr[e_mcroani.ACTIVE])
alpha = lerp(offalpha, onalpha, mcroani_arr[e_mcroani.ACTIVE])

color = merge_color(color, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
alpha = lerp(alpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

draw_box(switchx, switchy, 20, 14, false, color, alpha)

// Draw button
var buttonx, buttony;
buttonx = switchx + 2 + floor(8 * mcroani_arr[e_mcroani.GOAL_EASE])
buttony = switchy + 2
draw_box(buttonx, buttony, 8, 10, false, c_button_text, 1)
draw_box_bevel(buttonx, buttony, 8, 10, 1, setting_theme.name = "light")

// Draw hover outline
draw_box_hover(switchx, switchy, 20, 14, mcroani_arr[e_mcroani.PRESS])

// Label
draw_set_font(font_label)
draw_label(name, xx, yy + (h/2), fa_left, fa_middle, lerp(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]))

microani_update(mouseon, mouseclick, active, disabled, 0, thumbgoal)

if (tip != "")
{
	mouseon = app_mouse_box(xx + string_width(name) + 4, yy + (h/2) - 10, 20, 20) && content_mouseon && !disabled
	
	microani_set(tip, null, mouseon, false, false)
	color = merge_color(c_text_tertiary, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
	alpha = lerp(a_text_tertiary, a_text_secondary, mcroani_arr[e_mcroani.HOVER]) * lerp(1, .5, mcroani_arr[e_mcroani.DISABLED])
	
	draw_image(spr_icons, icons.HELP_CIRCLE, xx + string_width(name) + 16, yy + (h/2), 1, 1, color, alpha)
	
	if (!disabled)
		tip_set(text_get(tip), xx + string_width(name) + 4, yy + (h/2) - 10, 20, 20)
	
	microani_update(mouseon, false, false, disabled, 0)
}

// Press
if (pressed && mouse_left_released)
{
	if (script != null)
		script_execute(script, !active)
	
	return true
}