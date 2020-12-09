/// draw_settings_button(name, x, y, width, height, [primary_style, [script, [disabled]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [primary_style
/// @arg [script
/// @arg [disabled]]]
/// @desc Draw a drop down button that reveals settings when pressed.

var name, xx, yy, width, height, primary, script, disabled;
name = argument[0]
xx = argument[1]
yy = argument[2]
width = argument[3]
height = argument[4]
primary = false
script = null
disabled = false

if (argument_count > 5)
	primary = argument[5]

if (argument_count > 6)
	script = argument[6]

if (argument_count > 7)
	disabled = argument[7]

var mouseon, mouseclick;
mouseon = app_mouse_box(xx, yy, width, height) && content_mouseon && !disabled
mouseclick = mouseon && mouse_left

if (mouseon)
	mouse_cursor = cr_handpoint

microani_set(name, null, mouseon, mouseclick, false)

// Open menu
if (mouseon && mouse_left_released)
{
	window_busy = "settingsmenu"
	window_focus = ""
	app_mouse_clear()
	
	settings_menu_name = name
	settings_menu_ani = 0
	settings_menu_ani_type = "show"
	
	// Init
	settings_menu_primary = primary
	settings_menu_x = xx + ((width/2) * settings_menu_primary)
	settings_menu_y = yy + height + (2 * settings_menu_primary)
	settings_menu_button_h = height
	settings_menu_above = false
	settings_menu_steps = 0
	
	// Primary style
	if (script)
	{
		settings_menu_script = script
		settings_menu_h = 0
	}
	else
	{
		settings_menu_list = list_init(settings_menu_name)
		settings_menu_amount = ds_list_size(settings_menu_list.item)
		settings_menu_w = settings_menu_list.width
	
		//if ((settings_menu_x + (settings_menu_w/2)) > window_width)
		//	settings_menu_x += window_width - (settings_menu_x + (settings_menu_w/2))
	}
}

var menuactive, buttoncolor, buttonalpha;
menuactive = (settings_menu_name = name)

if (primary)
{
	buttoncolor = merge_color(c_accent, c_accent_hover, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.PRESS]))
	buttoncolor = merge_color(buttoncolor, c_accent_pressed, mcroani_arr[e_mcroani.PRESS])
	buttonalpha = lerp(1, a_accent_hover, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.PRESS]))
	buttonalpha = lerp(buttonalpha, a_accent_pressed, mcroani_arr[e_mcroani.PRESS])
	
	// Button background
	draw_box(xx, yy, width, height, false, buttoncolor, buttonalpha)
	
	// Bevel shading
	draw_box_bevel(xx, yy, width, height, 1)
	
	// Icon
	draw_image(spr_arrow_up_down_ani, mcroani_arr[e_mcroani.ACTIVE] * 15, xx + width/2, yy + height/2, 1 , 1, c_background, 1)
	
	// Accent accent hover outline
	draw_box_hover(xx, yy, width, height, mcroani_arr[e_mcroani.HOVER])
	
	microani_update(mouseon || menuactive, mouseclick || menuactive, menuactive, disabled)
}
else
{
	var backgroundcolor, backgroundalpha;
	backgroundcolor = c_overlay//merge_color(c_overlay, c_overlay, mcroani_arr[e_mcroani.ACTIVE])
	backgroundalpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.ACTIVE])

	backgroundalpha = lerp(backgroundalpha, 0, mcroani_arr[e_mcroani.HOVER])
	
	backgroundcolor = merge_color(backgroundcolor, c_accent_overlay, mcroani_arr[e_mcroani.PRESS])
	backgroundalpha = lerp(backgroundalpha, a_accent_overlay, mcroani_arr[e_mcroani.PRESS])
	
	buttoncolor = merge_color(c_text_secondary, c_accent, min(1, mcroani_arr[e_mcroani.PRESS] + mcroani_arr[e_mcroani.ACTIVE]))
	buttonalpha = lerp(a_text_secondary, 1, min(1, mcroani_arr[e_mcroani.PRESS] + mcroani_arr[e_mcroani.ACTIVE]))
	
	var prevalpha = draw_get_alpha();
	draw_set_alpha(prevalpha * lerp(1, .5, mcroani_arr[e_mcroani.DISABLED]))
	
	// Button background
	draw_box(xx, yy, width, height, false, backgroundcolor, backgroundalpha)
	
	// Icon
	draw_image(spr_chevrons, e_chevrons.DOWN, xx + width/2, yy + height/2, 1 , 1, buttoncolor, buttonalpha)
	
	draw_set_alpha(prevalpha)
	
	microani_update(mouseon, mouseclick, menuactive, disabled)
}

// Accent accent hover outline
draw_box_hover(xx, yy, width, height, mcroani_arr[e_mcroani.HOVER])
