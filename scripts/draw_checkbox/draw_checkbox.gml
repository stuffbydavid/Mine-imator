/// draw_checkbox(name, x, y, active, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script

var name, xx, yy, active, script;
var w, h, mouseon, pressed;
name = text_get(argument[0])
xx = argument[1]
yy = argument[2]
active = argument[3]
script = argument[4]

draw_set_font(font_emphasis)

w = 32 + string_width(name)
h = 24

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

// Mouse
var mouseon, mouseclick;
mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && (window_busy = "")
mouseclick = mouseon && mouse_left

pressed = false

if (mouseon)
{
    if (mouse_left || mouse_left_released)
        pressed = true
	
    mouse_cursor = cr_handpoint
}

// Set micro animation before drawing
microani_set(argument[0], script, mouseon, mouseclick, active)

var checkboxx, checkboxy;
checkboxx = xx
checkboxy = yy + (h/2) - 8

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

// Draw checkbox
draw_outline(checkboxx, checkboxy, 16, 16, 2 + (6 * mcroani_arr[e_mcroani.ACTIVE]), color, alpha, true)
draw_image(spr_checkbox_tick, 0, checkboxx + 8, checkboxy + 8, 1, 1, c_level_middle, 1 * mcroani_arr[e_mcroani.ACTIVE])

// Draw hover outline
draw_box_hover(checkboxx, checkboxy, 16, 16, mcroani_arr[e_mcroani.PRESS])

// Label
draw_label(name, xx + 24, yy + (h/2), fa_left, fa_middle, c_text_secondary, a_text_secondary)

microani_update(mouseon, mouseclick, active)

// Press
if (pressed && mouse_left_released)
{
	if (script != null)
		script_execute(script, !active)
	
	return true
}