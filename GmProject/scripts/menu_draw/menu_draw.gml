/// menu_draw()
/// @desc Draws open dropdown menus

function menu_draw()
{
	var m, menu_remove, menu_active, listh, menuh, contentmenu, yy, aniease, updatewidth, menu_x_draw, menu_wid_draw;
	menu_remove = null
	menu_current = null
	
	for (var i = 0; i < ds_list_size(menu_list); i++)
	{
		m = menu_list[|i]
		menu_active = (i = (ds_list_size(menu_list) - 1))
		menu_current = m
		contentmenu = (m.menu_type = e_menu.TRANSITION_LIST || m.menu_type = e_menu.CONTENT)
		updatewidth = false
		
		if (m.menu_window != window_get_current())
			continue
		
		// Animation
		if (m.menu_ani_type = "hide") //Hide
		{
			m.menu_ani -= test_reduced_motion(1, (0.06 * delta))
			if (m.menu_ani <= 0)
			{
				m.menu_ani = 0
				menu_remove = menu_current
				
				continue
			}
		}
		else if (m.menu_ani_type = "show") //Show
		{
			m.menu_ani += test_reduced_motion(1, (0.06 * delta))
			if (m.menu_ani >= 1)
			{
				m.menu_ani = 1
				m.menu_ani_type = ""
			}
		}
		
		// Draw invisible to initialize dynamic variables on first frame
		if (m.menu_steps = 0)
			draw_set_alpha(0)
		
		// Get draw height/Y
		m.menu_ani_ease = ease(((m.menu_ani_type = "show") ? "easeoutexpo" : "easeinexpo"), m.menu_ani)
		aniease = m.menu_ani_ease
		listh = (contentmenu ? m.menu_height : min(m.menu_amount, m.menu_show_amount) * m.menu_item_h) + (m.menu_padding * 2)
		menuh = (aniease * listh) + (12 * m.menu_scroll_horizontal.needed)
		
		yy = (m.menu_flip ? (m.menu_y - menuh) : (m.menu_y + m.menu_button_h)) 
		
		// Set content for menu background
		content_x = m.menu_x
		content_y = yy
		content_width = m.menu_w
		content_height = menuh
		
		menu_x_draw = lerp(m.menu_x_start, content_x, aniease)
		menu_wid_draw = lerp(m.menu_w_start, content_width, aniease)
		
		// Draw
		draw_box(menu_x_draw, yy, menu_wid_draw, menuh, false, c_level_top, 1)
		
		if (menuh > 2)
			draw_outline(menu_x_draw, yy, menu_wid_draw, menuh, 1, c_border, a_border, true)
		
		// Hide outline touching button
		draw_box(menu_x_draw + 1, yy + (m.menu_flip), menu_wid_draw - 2, menuh - 1, false, c_level_top, 1)
		
		// Drop shadow
		var shadowy, shadowh;
		shadowy = (m.menu_flip ? yy : yy - m.menu_button_h)
		shadowh = menuh + m.menu_button_h
		draw_dropshadow(menu_x_draw, shadowy, menu_wid_draw, shadowh, c_black, aniease)
		
		if (window_busy = "menu" && m.menu_ani_type != "hide" && menu_active)
			window_busy = ""
		
		// Scrollbars
		content_mouseon = app_mouse_box(m.menu_x, yy, m.menu_w, menuh)
		if (!contentmenu)
		{
			if (m.menu_scroll_vertical.needed && content_mouseon)
				window_scroll_focus = string(m.menu_scroll_vertical)
			
			if (m.menu_scroll_horizontal.needed && content_mouseon && keyboard_check(vk_shift))
				window_scroll_focus = string(m.menu_scroll_horizontal)
			
			if (m.menu_amount * m.menu_item_h > listh)
				scrollbar_draw(m.menu_scroll_vertical, e_scroll.VERTICAL, m.menu_x + m.menu_w - 12, yy, aniease * listh, (m.menu_amount * m.menu_item_h) + (m.menu_padding * 2))
			else
				m.menu_scroll_vertical.needed = false
			
			scrollbar_draw(m.menu_scroll_horizontal, e_scroll.HORIZONTAL, m.menu_x, yy + menuh - 12, m.menu_w - (12 * m.menu_scroll_vertical.needed), m.menu_list.width)
		}
		else
		{
			m.menu_scroll_vertical.needed = false
			m.menu_scroll_horizontal.needed = false
		}
		
		content_width = m.menu_w - (12 * m.menu_scroll_vertical.needed)
		content_height = menuh - (12 * m.menu_scroll_horizontal.needed)
		menu_wid_draw = lerp(m.menu_w_start, content_width, aniease)
		
		content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height)
		
		var mouseitem = null;
		draw_set_font(font_value)
		switch (m.menu_type)
		{
			case e_menu.LIST: // Normal list with images and caption
			case e_menu.LIST_SEAMLESS:
			case e_menu.TIMELINE:
			case e_menu.BIOME:
			{
				clip_begin(content_x, yy, content_width, content_height)
				
				if (!m.menu_flip)
					yy += (-listh + (listh * aniease))
				
				if (m.menu_scroll_vertical.needed)
					yy -= m.menu_scroll_vertical.value
				
				yy += m.menu_padding
				
				for (var j = 0; j < m.menu_amount; j++)
				{
					var item, itemy, itemh;
					
					item = m.menu_list.item[|j]
					itemy = yy
					itemh = m.menu_item_h
					
					// Toggle item and update list width
					if ((m.menu_value = item.value) && !item.toggled)
					{
						item.toggled = true
						updatewidth = true
					}
					
					list_item_draw(item, menu_x_draw, itemy, menu_wid_draw, m.menu_item_h, false, m.menu_margin, -m.menu_scroll_horizontal.value)
					
					if (item.hover)
						mouseitem = item
					
					yy += m.menu_item_h
				}
				
				clip_end()
				
				// Adjust component
				if (m.menu_type = e_menu.LIST || m.menu_type = e_menu.LIST_SEAMLESS)
				{
					if (updatewidth)
					{
						list_update_width(m.menu_list)
						//m.menu_list.width += 16
					}
					
					var w = m.menu_w;
					m.menu_w = max(m.menu_list.width + 16, m.menu_w)
					
					if ((m.menu_x + m.menu_w > (m.content_x + m.content_width)) && m.menu_x > window_width/2)
						m.menu_x = (m.menu_x + w) - m.menu_w
				}
				
				break
			}
			
			case e_menu.CONTENT: // Script with content
			case e_menu.TRANSITION_LIST:
			{
				clip_begin(0, content_y, window_width, content_height)
				
				if (m.menu_type = e_menu.CONTENT)
				{
					dx = content_x + 12
					dy = content_y + 12
					dw = content_width - 24
					dh = content_height - 24
					
					dy_start = dy
				}
				else
					dy_start = content_y
				
				script_execute(m.menu_script, m.menu_x, yy, m.menu_w, m.menu_height)
				
				m.menu_height_goal = (dy - dy_start)
				
				if (m.menu_type = e_menu.CONTENT)
					m.menu_height_goal += (24 - 8)
				
				clip_end()
				
				if (m.menu_steps = 0)
				{
					m.menu_height = m.menu_height_goal
					
					if (content_y + m.menu_height > window_height)
						m.menu_flip = true
				}
				else
				{
					// Prevent menu from moving down
					if (m.menu_flip)
						m.menu_height_goal = max(m.menu_height_goal, m.menu_height)
					
					m.menu_height += (m.menu_height_goal - m.menu_height) / max(1, 4/delta)
				}
				
				break
			}
		}
		
		// Extend timeline dropdown 
		if (m.menu_type = e_menu.TIMELINE && m.menu_item_extend)
		{
			app_mouse_clear()
			action_tl_extend(m.menu_item_extend)
			
			list_destroy(m.menu_list)
			
			m.menu_list = menu_timeline_init(m)
			m.menu_amount = ds_list_size(m.menu_list.item)
			m.menu_item_extend = null
			m.menu_list.show_ticks = false
		}
		
		// Extend biome dropdown
		if (m.menu_type = e_menu.BIOME && m.menu_item_extend)
		{
			app_mouse_clear()
			m.menu_item_extend.variants_extend = !m.menu_item_extend.variants_extend
			
			list_destroy(m.menu_list)
			
			m.menu_list = menu_biome_init(m)
			m.menu_amount = ds_list_size(m.menu_list.item)
			m.menu_item_extend = null
			m.menu_list.show_ticks = false
		}
		
		// Check click
		if (!(m.menu_scroll_vertical.needed && m.menu_scroll_vertical.mouseon) && !(m.menu_scroll_horizontal.needed && m.menu_scroll_horizontal.mouseon) && mouse_left_released && menu_active && m.menu_ani_type != "hide")
		{
			var close = false;
			
			if (contentmenu)
			{
				if (!content_mouseon && window_focus = "")
					close = true
			}
			else
			{
				if (mouseitem)
				{
					m.menu_ani = 2
					m.menu_value = mouseitem.value
					
					list_item_script = (mouseitem.script = null ? m.menu_script : mouseitem.script)
					list_item_script_value = m.menu_value
					
					for (var j = 0; j < m.menu_amount; j++)
					{
						var item = m.menu_list.item[|j];
						
						if (item != mouseitem)
							item.toggled = false
					}
					
					app_mouse_clear()
					close = true
				}
				
				if (!content_mouseon)
					close = true
			}
			
			if (close)
			{
				m.menu_ani = 1
				m.menu_ani_type = "hide"
				window_busy = (ds_list_size(menu_list) > 1 ? "menu" : "")
			}
		}
		
		// Revert alpha
		if (m.menu_steps = 0)
			draw_set_alpha(1)
		
		m.menu_steps++
		
		if (window_busy = "" && m.menu_ani_type != "hide" && menu_active)
			window_busy = "menu"
	}
	
	if (menu_remove != null)
	{
		instance_destroy(menu_remove)
		
		if (ds_list_size(menu_list) = 0)
			menu_popup = null
	}
	menu_current = null
}
