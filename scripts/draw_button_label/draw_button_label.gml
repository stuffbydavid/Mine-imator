/// draw_button_label(name, x, y, [width, [icon, [type, [script, [anchor, [disabled]]]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg [width
/// @arg [icon
/// @arg [type
/// @arg [script
/// @arg [anchor
/// @arg [disabled]]]]]]

var name, xx, yy, w, h, icon, type, script, anchor, disabled;
var cap, capwid, customw, mouseon, mouseclick;
name = argument[0]
xx = argument[1]
yy = argument[2]
w = null
h = 32
icon = null
type = e_button.PRIMARY
script = null
anchor = e_anchor.LEFT
disabled = false

if (argument_count > 3)
	w = argument[3]

if (argument_count > 4)
	icon = argument[4]
	
if (argument_count > 5)
	type = argument[5]

if (argument_count > 6)
	script = argument[6]

if (argument_count > 7)
	anchor = argument[7]

if (argument_count > 8)
	disabled = argument[8]

cap = text_get(name)

// Calculate width/position
draw_set_font(font_button)
capwid = string_width(cap)

if (w = null)
{
	w = capwid + (icon = null ? 24 : 52)
	customw = false
}
else
	customw = true

if (anchor = e_anchor.CENTER)
	xx = xx - floor(w/2)
else if (anchor = e_anchor.RIGHT)
	xx -= w

if (yy > content_y + content_height || yy + h < content_y || xx > content_x + content_width || xx + w < content_x)
	return 0

mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && !disabled
mouseclick = mouseon && mouse_left
microani_set(name, script, mouseon, mouseclick, false)

if (mouseon)
	mouse_cursor = cr_handpoint

var focus, backcolor, backalpha, linecolor, linealpha, contentcolor, contentalpha, contentx;
focus = max(mcroani_arr[e_mcroani.ACTIVE], mcroani_arr[e_mcroani.PRESS])

if (type = e_button.PRIMARY)
{
	backcolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER])
	backcolor = merge_color(backcolor, c_accent_pressed, focus)
	backcolor = merge_color(backcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	backalpha = lerp(1, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	
	contentcolor = c_button_text
	contentalpha = a_button_text
}
else
{
	backcolor = merge_color(c_overlay, c_accent_overlay, focus)
	backalpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.HOVER])
	backalpha = lerp(backalpha, a_accent_overlay, focus)
	backalpha = lerp(backalpha, 0, mcroani_arr[e_mcroani.DISABLED])
	
	contentcolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
	contentcolor = merge_color(contentcolor, c_accent, focus)
	contentalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
	contentalpha = lerp(contentalpha, 1, focus)
	
	linecolor = merge_color(c_border, c_accent, focus)
	linealpha = lerp(a_border, a_accent, focus)
}

// Background
draw_box(xx, yy, w, h, false, backcolor, backalpha)

// Bevel
if (type = e_button.PRIMARY)
	draw_box_bevel(xx, yy, w, h, 1)

// Outline
if (type = e_button.SECONDARY)
	draw_outline(xx, yy, w, h, 1, linecolor, linealpha, 1)

// Focus ring
draw_box_hover(xx, yy, w, h, mcroani_arr[e_mcroani.PRESS])

if (customw)
	contentx = floor((xx + w/2) - ((capwid + (icon = null ? 0 : 32)) / 2))
else
	contentx = floor(xx + (icon = null ? 12 : 8))

// Draw icon
if (icon != null)
{
	draw_image(spr_icons, icon, contentx + 12, yy + h/2, 1, 1, contentcolor, contentalpha)
	contentx += 32
}

// Draw label
draw_label(cap, contentx, yy + h/2, fa_left, fa_middle, contentcolor, contentalpha)

microani_update(mouseon, mouseclick, false, disabled)

if (mouseon && mouse_left_released)
{
	if (script != null)
		script_execute(script)
	
	return true
}