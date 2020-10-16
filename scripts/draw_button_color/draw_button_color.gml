/// draw_button_color(name, x, y, w, color, default, hsbmode, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg w
/// @arg color
/// @arg default
/// @arg hsbmode
/// @arg script

var name, xx, yy, w, color, def, hsbmode, script;
var w, h, mouseon, mouseclick;
name = argument0
xx = argument1
yy = argument2
w = argument3
color = argument4
def = argument5
hsbmode = argument6
script = argument7

h = 28
mouseon = app_mouse_box(xx, yy, 28, 28) && content_mouseon
mouseclick = mouseon && mouse_left

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

if (mouseon)
	mouse_cursor = cr_handpoint

//context_menu_area(xx, yy, 28, 28, "contextmenuvalue", color, e_value_type.COLOR, script, def)

microani_set(name, script, mouseon, mouseclick, popup = popup_colorpicker && popup_colorpicker.value_name = "settingsaccentcolor")

// Draw button background
draw_box(xx, yy, 28, 28, false, color, 1)

var buttoncolor, buttonalpha;
buttoncolor = merge_color(c_white, c_black, mcroani_arr[e_mcroani.PRESS])
buttonalpha = lerp(0, .17, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.PRESS]))
buttonalpha = lerp(buttonalpha, .20, mcroani_arr[e_mcroani.PRESS])

draw_box(xx, yy, 28, 28, false, buttoncolor, buttonalpha)
draw_outline(xx + 2, yy + 2, 24, 24, 2, (color_get_lum(color) > 150 ? c_black : c_white), a_border)

// Colorpicker icon
var iconcolor, iconalpha;
iconcolor = (color_get_lum(color) > 150 ? c_black : c_white)
iconalpha = (color_get_lum(color) > 150 ? 0.5 : 1)
draw_image(spr_icons, icons.EYEDROPPER, xx + 14, yy + 14, 1, 1, iconcolor, iconalpha * max(mcroani_arr[e_mcroani.HOVER], mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE]))

// Hover effect
draw_box_hover(xx, yy, 28, 28, mcroani_arr[e_mcroani.HOVER])

draw_label(text_get(name), floor(xx + 28 + 12), yy + 14, fa_left, fa_middle, lerp(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), font_emphasis)

microani_update(mouseon, mouseclick, popup = popup_colorpicker && popup_colorpicker.value_name = name)

if (mouseon && mouse_left_released)
	popup_colorpicker_show(name, color, def, script)
