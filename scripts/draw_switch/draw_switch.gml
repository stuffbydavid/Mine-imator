/// draw_switch(name, x, y, active, script, default, [tip, [disabled]])
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script
/// @arg default
/// @arg [tip
/// @arg [disabled]]

var name, xx, yy, active, script, def, tip, disabled;
var switchx, switchy, w, h, mouseon, pressed;
name = text_get(argument[0])
xx = argument[1]
yy = argument[2]
active = argument[3]
script = argument[4]
def = argument[5]
tip = ""
disabled = false

if (argument_count > 6)
	tip = argument[6]

if (argument_count > 7)
	disabled = argument[7]

switchx = (xx + dw - 24)
switchy = (yy + (28/2) - 8)
w = dw
h = 28

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

// Set micro animation before drawing
microani_set(argument[0], script, mouseon, mouseclick, active)

// Draw background
var color, alpha;
if (setting_theme != theme_light)
{
	color = c_text_tertiary
	alpha = a_text_tertiary
}
else
{
	color = c_text_secondary
	alpha = a_text_secondary
}

var backgroundcolor = merge_color(color, c_accent, mcroani_arr[e_mcroani.ACTIVE]);
var backgroundalpha = lerp(alpha, 1, mcroani_arr[e_mcroani.ACTIVE]);
draw_box(switchx, switchy, 24, 16, false, backgroundcolor, backgroundalpha)

// Draw button
var buttonx = switchx + 2 + (10 * mcroani_arr[e_mcroani.ACTIVE]);
var buttony = switchy + 2;
var buttoncolor = c_accent_overlay;
var buttonalpha = a_accent_overlay * mcroani_arr[e_mcroani.PRESS];
draw_box(buttonx, buttony, 10, 12, false, c_white, 1)
draw_box(buttonx, buttony, 10, 12, false, buttoncolor, buttonalpha)
draw_box_bevel(buttonx, buttony, 10, 12, 1, true)

// Disabled overlay
draw_box(switchx, switchy, 24, 16, false, c_background, .5 * mcroani_arr[e_mcroani.DISABLED])

// Draw hover outline
draw_box_hover(switchx, switchy, 24, 16, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.DISABLED]))

// Label
draw_set_font(font_emphasis)
draw_label(name, xx, yy + 14, fa_left, fa_middle, lerp(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]))

microani_update(mouseon, mouseclick, active, disabled)

if (tip != "")
{
	mouseon = app_mouse_box(xx + string_width(name) + 8, yy + 4, 20, 20) && content_mouseon && !disabled
	
	microani_set(tip, null, mouseon, false, false)
	buttoncolor = merge_color(c_text_tertiary, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
	buttonalpha = lerp(a_text_tertiary, a_text_secondary, mcroani_arr[e_mcroani.HOVER]) * lerp(1, .5, mcroani_arr[e_mcroani.DISABLED])
	
	draw_image(spr_icons, icons.HELP, xx + string_width(name) + 10 + 8, yy + 14, 1, 1, buttoncolor, buttonalpha)
	
	if (!disabled)
		tip_set(text_get(tip), xx + string_width(name) + 8, yy + 4, 20, 20)
	
	microani_update(mouseon, false, false, disabled)
}

// Press
if (pressed && mouse_left_released)
{
	if (script != null)
		script_execute(script, !active)
	
	return true
}