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

w = 26 + string_width(name)
h = 28

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
checkboxx = xx + 9
checkboxy = yy + (h/2)

var checkboxcolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.PRESS]);
checkboxcolor = merge_color(checkboxcolor, c_accent, mcroani_arr[e_mcroani.ACTIVE])
checkboxcolor = merge_color(checkboxcolor, c_accent_hover, mcroani_arr[e_mcroani.ACTIVE] * mcroani_arr[e_mcroani.HOVER])
checkboxcolor = merge_color(checkboxcolor, c_accent_pressed, mcroani_arr[e_mcroani.ACTIVE] * mcroani_arr[e_mcroani.PRESS])

var checkboxalpha = lerp(a_text_secondary, 1, mcroani_arr[e_mcroani.PRESS]);
checkboxalpha = lerp(checkboxalpha, 1, mcroani_arr[e_mcroani.ACTIVE])
checkboxalpha = lerp(checkboxalpha, a_accent_hover, mcroani_arr[e_mcroani.ACTIVE] * mcroani_arr[e_mcroani.HOVER])
checkboxalpha = lerp(checkboxalpha, a_accent_pressed, mcroani_arr[e_mcroani.ACTIVE] * mcroani_arr[e_mcroani.PRESS])

// Draw checkbox
draw_image(spr_checkbox, 0, checkboxx, checkboxy, 1, 1, checkboxcolor, checkboxalpha * (1.0 - mcroani_arr[e_mcroani.HOVER]))
draw_image(spr_checkbox, 1, checkboxx, checkboxy, 1, 1, checkboxcolor, checkboxalpha * mcroani_arr[e_mcroani.HOVER] * (1.0 - mcroani_arr[e_mcroani.ACTIVE]))
draw_image(spr_checkbox, 2, checkboxx, checkboxy, 1, 1, checkboxcolor, checkboxalpha * mcroani_arr[e_mcroani.ACTIVE])

// Draw hover outline
draw_box_hover(checkboxx - 9, checkboxy - 9, 18, 18, mcroani_arr[e_mcroani.HOVER])

// Label
draw_label(name, xx + 26, yy + (h/2), fa_left, fa_middle, c_text_secondary, a_text_secondary)

microani_update(mouseon, mouseclick, active)

// Press
if (pressed && mouse_left_released)
{
	if (script != null)
		script_execute(script, !active)
	
	return true
}