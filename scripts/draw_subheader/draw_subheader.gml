/// draw_subheader(category, x, y)
/// @arg category
/// @arg x
/// @arg y

var cat, xx, yy, h, w, mouseon;
cat = argument0
xx = argument1
yy = argument2
h = 16

draw_set_font(font_subheading)
w = h + 4 + string_width(text_get(cat.name))

mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon

microani_set(cat.name + "close", null, false, false, cat.show, false)

var color, alpha, focus, frame;
focus = max(mcroani_arr[e_mcroani.ACTIVE], mcroani_arr[e_mcroani.PRESS])

color = merge_color(c_text_tertiary, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
color = merge_color(color, c_accent,focus)

alpha = lerp(a_text_tertiary, a_text_secondary, mcroani_arr[e_mcroani.HOVER])
alpha = lerp(alpha, a_accent, focus)

frame = floor((sprite_get_number(spr_chevron_ani) - 1) * mcroani_arr[e_mcroani.ACTIVE])

draw_image(spr_chevron_ani, frame, xx + h/2, yy + h/2, 1, 1, color, alpha)
draw_label(text_get(cat.name), xx + h + 4, yy + (h/2) - 1, fa_left, fa_middle, color, alpha)

microani_update(mouseon, mouseon && mouse_left, cat.show)

if (mouseon)
{
	mouse_cursor = cr_handpoint
	
	if (mouse_left_released)
		cat.show = !cat.show
}
