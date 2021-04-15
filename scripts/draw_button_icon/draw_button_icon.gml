/// draw_button_icon(name, x, y, width, height, value, icon, [script, [disabled, [tip, [sprite]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg value
/// @arg icon
/// @arg [script
/// @arg [disabled
/// @arg [tip
/// @arg [sprite]]]]

var name, xx, yy, wid, hei, value, icon, script, disabled, tip, sprite;
var mouseon, animated;

name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
hei = argument[4]
value = argument[5]
icon = argument[6]
script = null
disabled = false
tip = ""
sprite = spr_icons

if (argument_count > 7)
	script = argument[7]

if (argument_count > 8)
	disabled = argument[8]

if (argument_count > 9)
	tip = argument[9]

if (argument_count > 10)
	if (argument[10] != null)
		sprite = argument[10]

if (tip != "")
	tip_set(text_get(tip), xx, yy, wid, hei)

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

mouseon = (content_mouseon && !disabled && app_mouse_box(xx, yy, wid, hei))
animated = (sprite != spr_icons && sprite != null && icon = null && sprite_get_number(sprite) > 1)

if (mouseon)
	mouse_cursor = cr_handpoint

microani_set(name, script, mouseon, mouseon && mouse_left, value)

// Hover outline
draw_box_hover(xx, yy, wid, hei, mcroani_arr[e_mcroani.PRESS])

// Background
var onbackcolor, onbackalpha, oniconcolor, oniconalpha, offbackcolor, offbackalpha, officoncolor, officonalpha;

offbackcolor = c_overlay
offbackcolor = merge_color(offbackcolor, c_accent_overlay, mcroani_arr[e_mcroani.PRESS])
offbackalpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.HOVER])
offbackalpha = lerp(offbackalpha, a_accent_overlay, mcroani_arr[e_mcroani.PRESS])

onbackcolor = merge_color(c_accent_overlay, c_overlay, mcroani_arr[e_mcroani.HOVER])
onbackcolor = merge_color(onbackcolor, c_accent_overlay, mcroani_arr[e_mcroani.PRESS])
onbackalpha = lerp(a_accent_overlay, a_overlay, mcroani_arr[e_mcroani.HOVER])
onbackalpha = lerp(onbackalpha, a_accent_overlay, mcroani_arr[e_mcroani.PRESS])

onbackcolor = merge_color(offbackcolor, onbackcolor, mcroani_arr[e_mcroani.ACTIVE] * !animated)
onbackalpha = lerp(offbackalpha, onbackalpha, mcroani_arr[e_mcroani.ACTIVE] * !animated)
onbackalpha = lerp(onbackalpha, 0, mcroani_arr[e_mcroani.DISABLED])

officoncolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
officoncolor = merge_color(officoncolor, c_accent, mcroani_arr[e_mcroani.PRESS])
officonalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
officonalpha = lerp(officonalpha, 1, mcroani_arr[e_mcroani.PRESS])

oniconcolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER])
oniconcolor = merge_color(oniconcolor, c_accent_pressed, mcroani_arr[e_mcroani.PRESS])
oniconalpha = merge_color(a_accent, a_accent_hover, mcroani_arr[e_mcroani.HOVER])
oniconalpha = merge_color(oniconalpha, a_accent_pressed, mcroani_arr[e_mcroani.PRESS])

oniconcolor = merge_color(officoncolor, oniconcolor, mcroani_arr[e_mcroani.ACTIVE] * !animated)
oniconalpha = lerp(officonalpha, oniconalpha, mcroani_arr[e_mcroani.ACTIVE] * !animated)

oniconcolor = merge_color(oniconcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
oniconalpha = lerp(oniconalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

draw_box(xx, yy, wid, hei, false, onbackcolor, onbackalpha)

// Animated icon(if 'icon' is a sprite)
if (animated)
{
	var frame = floor((sprite_get_number(sprite) - 1) * mcroani_arr[e_mcroani.ACTIVE]);
	draw_image(sprite, frame, xx + wid/2, yy + hei/2, 1, 1, oniconcolor, oniconalpha)
}
else // Icon
	draw_image(sprite, icon, xx + wid/2, yy + hei/2, 1, 1, oniconcolor, oniconalpha)

microani_update(mouseon, mouseon && mouse_left, value, disabled)

if (mouseon && mouse_left_released)
{
	if (script != null)
		script_execute(script, !value)
	
	app_mouse_clear()
	
	return true
}
