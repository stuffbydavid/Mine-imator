/// draw_button_menu(name, type, x, y, width, height, value, text, script, [disabled, [texture, [icon, [caption]]]])
/// @arg name
/// @arg type
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg value
/// @arg text
/// @arg script
/// @arg [disabled
/// @arg [texture
/// @arg [icon
/// @arg [caption]]]

var name, type, xx, yy, wid, hei, value, text, script, tex, disabled, icon, caption;
var flip, mouseon, cap;
name = argument[0]
type = argument[1]
xx = argument[2] 
yy = argument[3]
wid = argument[4]
hei = argument[5]
value = argument[6]
text = argument[7]
script = argument[8]

if (argument_count > 9)
	disabled = argument[9]
else
	disabled = false
	
if (argument_count > 10)
	tex = argument[10]
else
	tex = null

if (argument_count > 11)
	icon = argument[11]
else
	icon = null

if (argument_count > 12)
	caption = argument[12]
else
	caption = ""

// Caption
if (menu_model_current != null)
{
	cap = minecraft_asset_get_name("modelstate", name)
	name = "modelstate" + name
}
else if (menu_block_current != null)
{
	cap = minecraft_asset_get_name("blockstate", name)
	name = "blockstate" + name
}
else
{
	if (type = e_menu.LIST_NUM)
	{
		cap = text_get(name, menu_count)
		name = name + string(menu_count)
	}
	else
		cap = text_get(name)
}

flip = (yy + hei + hei * 4 > window_height)

microani_set(name, null, false, false, false)

var textcolor, textalpha;
textcolor = merge_color(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
textalpha = lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

// Caption
if (dh > (hei + 20))
{
	draw_label(cap, xx, yy + 16, fa_left, fa_bottom, textcolor, textalpha, font_emphasis)
	yy += 20
}

// Button
var bordercolor, borderalpha;
bordercolor = merge_color(c_border, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
borderalpha = lerp(a_border, a_text_secondary, mcroani_arr[e_mcroani.HOVER])
bordercolor = merge_color(bordercolor, c_accent, mcroani_arr[e_mcroani.PRESS])
borderalpha = lerp(borderalpha, a_accent, mcroani_arr[e_mcroani.PRESS])

if (menu_name = name)
	draw_box(xx, yy, wid, hei, false, c_background, 1)

draw_outline(xx, yy, wid, hei, 1, bordercolor, borderalpha)
draw_box_hover(xx - 1, yy - 1, wid + 2, hei + 2, mcroani_arr[e_mcroani.HOVER])

// Mouse
mouseon = app_mouse_box(xx, yy, wid, hei) && !disabled && content_mouseon

if (mouseon)
	mouse_cursor = cr_handpoint

// Item
var item = list_item_add(text, null, caption, tex, icon, -1, null, false, false);
item.disabled = disabled
list_item_draw(item, xx, yy, wid, hei, false, 8)
instance_destroy(item)

// Arrow
draw_image(spr_arrow_up_down_ani, (mcroani_arr[e_mcroani.ACTIVE] * 15), xx + wid - hei / 2, yy + hei / 2, 1, 1, textcolor, textalpha)

// Disabled overlay
draw_box(xx, yy, wid, hei, false, c_overlay, a_overlay * mcroani_arr[e_mcroani.DISABLED])

microani_update(mouseon, mouseon && mouse_left, (menu_name = name ? !flip : flip), disabled)

// Update menu position
if (menu_name = name)
{
	menu_x = xx
	menu_y = yy
}

// Check click
if (mouseon && mouse_left_released)
{
	window_busy = "menu"
	window_focus = string(menu_scroll)
	app_mouse_clear()
	
	menu_name = name
	menu_type = type
	menu_temp_edit = temp_edit
	menu_script = script
	menu_value = value
	menu_ani = 0
	menu_ani_type = "show"
	menu_flip = flip
	menu_x = xx
	menu_y = yy
	menu_w = wid
	menu_button_h = hei
	menu_item_w = wid
	menu_item_h = menu_button_h
	menu_include_tl_edit = (menu_name != "timelineeditorparent")
	menu_model_state = menu_model_state_current
	menu_block_state = menu_block_state_current
	menu_margin = 8
	
	//menu_list_init()
	
	// Init
	menu_clear()
	if (type = e_menu.LIST)
		menu_list = list_init(menu_name)
	else if (type = e_menu.TIMELINE)
		menu_timeline_init()
	else
		menu_transition_init()
	
	menu_amount = ds_list_size(menu_list.item)
	menu_focus_selected()
		
	// Flip
	if (menu_flip)
		menu_show_amount = floor((menu_y * 0.9) / menu_item_h)
	else
		menu_show_amount = floor(((window_height - (menu_y + menu_button_h)) * 0.9) / menu_item_h)
	
	return true
}

return false
