/// draw_button_menu(name, type, x, y, width, height, value, text, script, [disabled, [texture, [icon, [caption, [texcolor, texalpha]]]]])
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
/// @arg [caption
/// @arg [texcolor
/// @arg texalpha]]]]]

var name, type, xx, yy, wid, hei, value, text, script, tex, disabled, icon, caption, texcolor, texalpha;
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

if (argument_count > 13)
{
	texcolor = argument[13]
	texalpha = argument[14]
}
else
{
	texcolor = c_white
	texalpha = 1
}

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

flip = (yy + hei + hei * 8 > window_height)

microani_set(name, null, false, false, false)

var textcolor, textalpha, bordercolor, borderalpha, chevroncolor, chevronalpha;
textcolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.ACTIVE])
textcolor = merge_color(textcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
textalpha = lerp(a_text_secondary, a_accent, mcroani_arr[e_mcroani.ACTIVE])
textalpha = lerp(textalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

// Caption
if (dh > (hei + (label_height + 8)))
{
	draw_label(cap, xx, yy - 3, fa_left, fa_top, textcolor, textalpha, font_emphasis)
	yy += (label_height + 8)
}

// Button
bordercolor = merge_color(c_border, c_text_secondary, mcroani_arr[e_mcroani.HOVER])
bordercolor = merge_color(bordercolor, c_accent, mcroani_arr[e_mcroani.PRESS])
borderalpha = lerp(a_border, a_text_secondary, mcroani_arr[e_mcroani.HOVER])
borderalpha = lerp(borderalpha, a_accent, mcroani_arr[e_mcroani.PRESS])

if (menu_name = name)
	draw_box(xx, yy, wid, hei, false, c_background, 1)

draw_outline(xx, yy, wid, hei, 1, bordercolor, borderalpha, true)
draw_box_hover(xx, yy, wid, hei, mcroani_arr[e_mcroani.PRESS])

// Mouse
mouseon = app_mouse_box(xx, yy, wid, hei) && !disabled && content_mouseon

if (mouseon)
	mouse_cursor = cr_handpoint

// Item
var item = list_item_add(text, null, caption, tex, icon, -1, null, false, false);
item.disabled = disabled

if (type = e_menu.TRANSITION_LIST)
{
	item.thumbnail_blend = c_text_secondary
	item.thumbnail_alpha = a_text_secondary
}
else
{
	item.thumbnail_blend = texcolor
	item.thumbnail_alpha = texalpha
}

list_item_draw(item, xx, yy, wid, hei, false, null, null, false)
instance_destroy(item)

// Chevron
chevroncolor = merge_color(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
chevronalpha = lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

draw_image(spr_chevrons, 0, xx + wid - hei / 2, yy + hei / 2, 1, 1, chevroncolor, chevronalpha * (1 - mcroani_arr[e_mcroani.CUSTOM_LINEAR]))
draw_image(spr_chevrons, 1, xx + wid - hei / 2, yy + hei / 2, 1, 1, chevroncolor, chevronalpha * mcroani_arr[e_mcroani.CUSTOM_LINEAR])

// Disabled overlay
draw_box(xx, yy, wid, hei, false, c_overlay, a_overlay * mcroani_arr[e_mcroani.DISABLED])

microani_update(mouseon, mouseon && mouse_left, (menu_name = name && menu_ani_type != "hide"), disabled, ((menu_name = name && menu_ani_type != "hide") ? !flip : flip))

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
	//window_focus = string(menu_scroll_vertical)
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
	menu_margin = 0//8
	menu_transition = null
	menu_steps = 0
	menu_floating = false
	
	// Init
	menu_clear()
	
	if (type = e_menu.LIST)
		menu_list = list_init(menu_name)
	else if (type = e_menu.TIMELINE)
		menu_list = menu_timeline_init()
	else if (type = e_menu.TRANSITION_LIST)
		menu_list = menu_transition_init()
	
	menu_amount = menu_list = null ? 0 : ds_list_size(menu_list.item)
	menu_focus_selected()
	
	// Flip
	if (menu_flip)
		menu_show_amount = floor((menu_y * 0.9) / menu_item_h)
	else
		menu_show_amount = floor(((window_height - (menu_y + menu_button_h)) * 0.9) / menu_item_h)
	
	return true
}

return false
