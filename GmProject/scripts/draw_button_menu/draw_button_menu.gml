/// draw_button_menu(name, type, x, y, width, height, value, text, script|menuscript, [disabled, [texture, [icon, [caption, [texcolor, texalpha, [capwid]]]]]])
/// @arg name
/// @arg type
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg value
/// @arg text
/// @arg script|drawscript
/// @arg [disabled
/// @arg [texture
/// @arg [icon
/// @arg [caption
/// @arg [texcolor
/// @arg texalpha
/// @arg [capwid]]]]]

function draw_button_menu()
{
	var name, type, xx, yy, wid, hei, value, text, script, tex, disabled, icon, caption, texcolor, texalpha, capwid;
	var flip, mouseon, cap, menuactive, menuhide, menuid, nameid;
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
		
		if (texcolor = null)
			texcolor = c_white
		
		if (texalpha = null)
			texalpha = 1
	}
	else
	{
		texcolor = c_white
		texalpha = 1
	}
	
	if (argument_count > 15)
		capwid = argument[15]
	else
		capwid = null
	
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
		cap = text_get(name)
	
	if (menu_bench)
		nameid = "bench" + name
	else if (content_tab = null && popup != null)
		nameid = popup.name + name
	else
		nameid = name
	
	// Check if menu is currently active
	menuactive = false
	menuhide = false
	menuid = null
	
	for (var i = 0; i < ds_list_size(menu_list); i++)
	{
		if (menu_list[|i].menu_name = nameid)
		{
			menuactive = true
			menuhide = menu_list[|i].menu_ani_type = "hide"
			menuid = menu_list[|i]
		}
	}
	
	flip = (yy + hei + hei * 8 > window_height)
	
	microani_set(nameid, null, false, false, false)
	
	var textcolor, textalpha, bordercolor, borderalpha, chevroncolor, chevronalpha, fadealpha, animation;
	textcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	textcolor = merge_color(textcolor, c_accent, microani_arr[e_microani.ACTIVE])
	textcolor = merge_color(textcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
	textalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	textalpha = lerp(textalpha, a_accent, microani_arr[e_microani.ACTIVE])
	textalpha = lerp(textalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
	fadealpha = microani_arr[e_microani.FADE]
	animation = current_microani
	
	// Caption
	if (type != e_menu.LIST_SEAMLESS)
	{
		draw_set_font(font_label)
		
		if (capwid = null && (!window_compact || app.panel_compact))
		{
			draw_label(string_limit(cap, dw), xx, yy - 3, fa_left, fa_top, textcolor, textalpha)
			yy += (label_height + 8)
		}
		else
		{
			if (capwid = null && window_compact)
			{
				cap = string_limit(cap, dw/3)
				capwid = dw/3
			}
			
			draw_label(cap, xx, yy + hei/2, fa_left, fa_middle, textcolor, textalpha)
			wid -= capwid
			xx += capwid
		}
		
		animation.fade.value = 1
	}
	
	if (menuactive)
	{
		xx = lerp(xx, max(dx, menuid.menu_x), menuid.menu_ani_ease)
		wid = lerp(wid, min(dw, menuid.menu_w), menuid.menu_ani_ease)
	}
	
	// Button
	bordercolor = merge_color(c_border, c_text_secondary, microani_arr[e_microani.HOVER])
	bordercolor = merge_color(bordercolor, c_accent, microani_arr[e_microani.PRESS])
	bordercolor = merge_color(bordercolor, c_accent, microani_arr[e_microani.ACTIVE])
	borderalpha = lerp(a_border, a_text_secondary, microani_arr[e_microani.HOVER])
	borderalpha = lerp(borderalpha, a_accent, microani_arr[e_microani.PRESS])
	borderalpha = lerp(borderalpha, a_accent, microani_arr[e_microani.ACTIVE])
	
	draw_box(xx, yy, wid, hei, false, c_level_top, draw_get_alpha())
	draw_outline(xx, yy, wid, hei, 1, bordercolor, borderalpha * fadealpha, true)
	
	draw_box_hover(xx, yy, wid, hei, microani_arr[e_microani.PRESS])
	
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
		item.thumbnail_backdrop = false
	}
	else
	{
		item.thumbnail_blend = texcolor
		item.thumbnail_alpha = texalpha
	}
	
	list_item_draw(item, xx, yy, wid, hei, false, null, null, false)
	instance_destroy(item)
	
	// Chevron
	chevroncolor = merge_color(c_text_tertiary, c_text_secondary, microani_arr[e_microani.HOVER])
	chevroncolor = merge_color(chevroncolor, c_accent, microani_arr[e_microani.ACTIVE])
	chevroncolor = merge_color(chevroncolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
	chevronalpha = lerp(a_text_tertiary, a_text_secondary, microani_arr[e_microani.HOVER])
	chevronalpha = lerp(chevronalpha, a_accent, microani_arr[e_microani.ACTIVE])
	chevronalpha = lerp(chevronalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	draw_image(spr_icons, icons.CHEVRON_DOWN_TINY, xx + wid - 12, yy + hei / 2, 1, 1, chevroncolor, chevronalpha * (1 - microani_arr[e_microani.CUSTOM_LINEAR]))
	draw_image(spr_icons, icons.CHEVRON_UP_TINY, xx + wid - 12, yy + hei / 2, 1, 1, chevroncolor, chevronalpha * microani_arr[e_microani.CUSTOM_LINEAR])
	
	// Disabled overlay
	draw_box(xx, yy, wid, hei, false, c_overlay, a_overlay * microani_arr[e_microani.DISABLED])
	
	microani_update(mouseon, mouseon && mouse_left, (menuactive && !menuhide), disabled, ((menuactive && !menuhide) ? !flip : flip))
	
	// Update menu position
	if (menuactive)
	{
		menu_x = xx
		menu_y = yy
	}
	
	// Quick, re-open!
	if (mouseon && mouse_left_released && menuhide)
	{
		window_busy = "menu"
		menuid.menu_ani_type = "show"
		app_mouse_clear()
	}
	
	// Check click
	if (mouseon && mouse_left_released && !menuhide)
	{
		var m = null;
		for (var i = 0; i < ds_list_size(menu_list); i++)
		{
			if (menu_list[|i].menu_name = nameid)
			{
				m = menu_list[|i]
				break;
			}
		}
		
		if (m = null)
			m = new_obj(obj_menu)
		
		m.menu_busy_prev = window_busy
		
		window_busy = "menu"
		window_focus = ""//string(menu_scroll_vertical)
		app_mouse_clear()
		
		m.menu_name = nameid
		m.menu_type = type
		m.menu_window = window_get_current()
		m.menu_temp_edit = temp_edit
		m.menu_script = script
		m.menu_value = value
		m.menu_ani = 0
		m.menu_ani_type = "show"
		m.menu_flip = flip
		m.menu_x = xx
		m.menu_x_start = xx
		m.menu_y = yy
		m.menu_w = wid
		m.menu_w_start = wid
		m.menu_button_h = hei
		m.menu_item_w = wid
		m.menu_item_h = m.menu_button_h
		m.menu_include_tl_edit = (m.menu_name != "timelineeditorparent")
		m.menu_margin = 0//8
		m.menu_transition = null
		m.menu_steps = 0
		m.menu_floating = false
		
		m.content_x = content_x
		m.content_width = content_width
		
		menu_current = m
		
		// Init
		menu_model_state = menu_model_state_current
		menu_block_state = menu_block_state_current
		
		menu_armor_piece = popup_armor_editor.piece_current
		menu_armor_piece_data = popup_armor_editor.piece_data_id
		
		if (type = e_menu.LIST || type = e_menu.LIST_SEAMLESS)
			m.menu_list = list_init(name)
		else if (type = e_menu.TIMELINE)
			m.menu_list = menu_timeline_init(m)
		else if (type = e_menu.BIOME)
			m.menu_list = menu_biome_init(m)
		
		m.menu_amount = m.menu_list = null ? 0 : ds_list_size(m.menu_list.item)
		
		if (m.menu_list != null)
			m.menu_list.show_ticks = false
		
		with (m)
			menu_focus_selected()
		
		// Flip
		if (m.menu_flip)
			m.menu_show_amount = floor((m.menu_y * 0.9) / m.menu_item_h)
		else
			m.menu_show_amount = floor(((window_height - (m.menu_y + m.menu_button_h)) * 0.9) / m.menu_item_h)
		
		current_microani = animation
		
		menu_popup = popup
		return true
	}
	
	current_microani = animation
	return false
}
