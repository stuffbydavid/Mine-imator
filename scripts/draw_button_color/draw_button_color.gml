/// draw_button_color(name, x, y, w, color, default, hsbmode, script, tbx)
/// @arg name
/// @arg x
/// @arg y
/// @arg w
/// @arg color
/// @arg default
/// @arg hsbmode
/// @arg script
/// @arg tbx

var name, xx, yy, w, color, def, hsbmode, script, tbx;
var textx, textw, w, h, mouseon, mouseclick, swatchmouseon, swatchclick, update, active;
name = argument[0]
xx = argument[1]
yy = argument[2]
w = argument[3]
color = argument[4]
def = argument[5]
hsbmode = argument[6]
script = argument[7]
tbx = null
textx = xx
textw = w

if (argument_count > 8)
	tbx = argument[8]

h = 24 + (label_height + 8)

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

yy += (label_height + 8)
h = 24

active = (settings_menu_name = "colorpicker" && colorpicker.value_name = name)
mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon
mouseclick = mouseon && mouse_left

swatchmouseon = app_mouse_box(xx, yy, h, h) && content_mouseon
swatchclick = mouseon && mouse_left

if (mouseon)
	mouse_cursor = cr_handpoint

context_menu_area(xx, yy, w, h, "contextmenuvalue", color, e_context_type.COLOR, script, def)
microani_set(name, script, mouseon, mouseclick, active, false, 1, true)

// Caption
draw_label(text_get(name), xx, yy - 4, fa_left, fa_bottom, lerp(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), font_emphasis)

// Color preview
draw_box(xx, yy, w, h, false, c_level_top, draw_get_alpha())
draw_box(xx + 4, yy + 4, 16, 16, false, color, 1)
draw_outline(xx + 4, yy + 4, 16, 16, 1, c_border, a_border, 1)

// Draw button outline
var bordercolor, borderalpha;
bordercolor = merge_color(c_border, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
bordercolor = merge_color(bordercolor, c_accent, max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE]))
bordercolor = merge_color(bordercolor, c_border, mcroani_arr[e_mcroani.DISABLED])
borderalpha = lerp(a_border, a_text_secondary, mcroani_arr[e_mcroani.HOVER])
borderalpha = lerp(borderalpha, a_accent, max(mcroani_arr[e_mcroani.PRESS], mcroani_arr[e_mcroani.ACTIVE]))
borderalpha = lerp(borderalpha, a_border, mcroani_arr[e_mcroani.DISABLED])

draw_outline(xx, yy, w, h, 1, bordercolor, borderalpha, true)
draw_box_hover(xx, yy, w, h, mcroani_arr[e_mcroani.PRESS])

// Button swatch
var iconcolor, iconalpha;
iconcolor = (color_get_lum(color) > 150 ? c_black : c_white)
iconalpha = (color_get_lum(color) > 150 ? 0.5 : 1)

// Color button doesn't have disabled state, use disabled ease for swatch hover
draw_image(spr_icons, icons.EYEDROPPER, textx + floor(h/2), yy + floor(h/2), 1, 1, iconcolor, iconalpha * mcroani_arr[e_mcroani.CUSTOM])

// Hex input
draw_set_font(font_value)
textx += 28
textw -= 28

draw_label("#", textx, yy + 4, fa_left, fa_top, c_text_secondary, a_text_secondary)
textx += string_width("#")
textw -= string_width("#")

update = textbox_draw(tbx, textx, yy + 4, textw, 18, true)

if (update && (script != null))
	script_execute(script, hex_to_color(tbx.text))

microani_update(mouseon || window_focus = string(tbx), mouseclick, active || window_focus = string(tbx), false, swatchmouseon)

// Idle update
if (window_focus != string(tbx) && color_to_hex(color) != tbx.text)
	tbx.text = color_to_hex(color)

if (swatchmouseon && mouse_left_released)
	colorpicker_show(name, color, def, script, xx, yy, w, h)

if (mouseon && !swatchmouseon && mouse_left_pressed && (window_focus != string(tbx)))
{
	window_focus = string(tbx)
	app_mouse_clear()
}
