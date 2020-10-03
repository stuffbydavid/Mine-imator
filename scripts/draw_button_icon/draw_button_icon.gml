/// draw_button_icon(name, x, y, width, height, value, icon, [script, [disabled, [tip, [sprite, [constrast]]]]])
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
/// @arg [sprite
/// @arg [contrast]]]]

var name, xx, yy, wid, hei, value, icon, script, disabled, tip, sprite, constrast;
var small, mouseon;

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
constrast = false

if (argument_count > 7)
	script = argument[7]
	
if (argument_count > 8)
	disabled = argument[8]

if (argument_count > 9)
	tip = argument[9]
	
if (argument_count > 10)
	sprite = argument[10]

if (argument_count > 11)
	constrast = argument[11]

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

small = ((wid < 28) || (hei < 28))

if (small)
{
	mouseon = (content_mouseon && !disabled && app_mouse_box(xx, yy, wid, hei))
	
	if (mouseon && tip != "")
		tip_set(text_get(tip), xx, yy, wid, hei)
}
else
{
	mouseon = (content_mouseon && !disabled && app_mouse_box(xx + 2, yy + 2, wid - 4, hei - 4))
	
	if (mouseon && tip != "")
		tip_set(text_get(tip), xx + 2, yy + 2, wid - 4, hei - 4)
}

if (mouseon)
	mouse_cursor = cr_handpoint

microani_set(name, script, mouseon, mouseon && mouse_left, value)

// Hover outline
draw_box_hover(xx, yy, wid, hei, mcroani_arr[e_mcroani.HOVER])

// Background
var backgroundcolor, backgroundalpha;
backgroundcolor = merge_color(c_accent_overlay, c_overlay, mcroani_arr[e_mcroani.ACTIVE])
backgroundalpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.ACTIVE])

backgroundalpha = lerp(backgroundalpha, 0, mcroani_arr[e_mcroani.HOVER])

backgroundcolor = merge_color(backgroundcolor, c_accent_overlay, mcroani_arr[e_mcroani.PRESS])
backgroundalpha = lerp(backgroundalpha, a_accent_overlay, mcroani_arr[e_mcroani.PRESS])

var prevalpha = draw_get_alpha();
draw_set_alpha(prevalpha * lerp(1, .5, mcroani_arr[e_mcroani.DISABLED]))

draw_box(xx, yy, wid, hei, false, backgroundcolor, backgroundalpha)

var iconcolor, iconalpha;

if (constrast)
{
	iconcolor = c_background
	iconalpha = 1
}
else
{
	iconcolor = c_text_secondary
	iconalpha = a_text_secondary
}

// Animated icon(if 'icon' is a sprite)
if (sprite != spr_icons && sprite != null)
{
	var frame = floor((sprite_get_number(sprite) - 1) * mcroani_arr[e_mcroani.ACTIVE_LINEAR]);
	draw_image(sprite, frame, xx + wid/2, yy + wid/2, 1, 1, iconcolor, iconalpha)
}
else // Icon
	draw_image(spr_icons, icon, xx + wid/2, yy + wid/2, 1, 1, merge_color(iconcolor, c_accent, mcroani_arr[e_mcroani.ACTIVE]), lerp(iconalpha, 1, mcroani_arr[e_mcroani.ACTIVE]))

draw_set_alpha(prevalpha)

microani_update(mouseon, mouseon && mouse_left, value, disabled)

if (mouseon && mouse_left_released)
{
	if (script != null)
		script_execute(script, !value)
	
	return true
}
