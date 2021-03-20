/// draw_tooltip_label(text, icon, type)
/// @arg text
/// @arg icon
/// @arg type

var text, icon, type, color;
text = argument0
icon = argument1
type = argument2

color = setting_theme.toast_color[type]
text = string_wrap(text_get(text), dw - 16)

// Undo previous component padding
dy -= 8

tab_control(24 + string_count("\n", text) * 14)
draw_image(spr_icons, icon, dx + 12, dy + (tab_control_h/2), 1, 1, color, 1)
draw_label(text, dx + 32, dy + (tab_control_h/2), fa_left, fa_middle, c_text_secondary, a_text_secondary, font_caption)
tab_next()
