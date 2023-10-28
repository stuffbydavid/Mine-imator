/// popup_pattern_editor_draw()

function popup_pattern_editor_draw()
{
	dx_start = dx
	
	// Model preview
	popup.preview.update = true
	setting_wind_enable = false
	preview_draw(popup.preview, dx, dy, 200, 332)
	setting_wind_enable = true
	
	dx += 200 + 8
	
	draw_separator_vertical(dx, dy + 4, 332 - 8)
	dx += 8
	
	var listy, listw;
	listy = dy
	listw = dw - (dx - dx_start)
	
	// Add layer
	if (draw_button_label("patterneditoraddlayer", dx, dy, listw, icons.PLUS, e_button.SECONDARY))
	{
		var pt = 1 + irandom(ds_list_size(minecraft_pattern_list) - 2);
		ds_list_add(popup.pattern_list_edit, minecraft_pattern_list[|pt])
		ds_list_add(popup.pattern_color_list_edit, minecraft_swatch_dyes.colors[irandom(array_length(minecraft_swatch_dyes.colors) - 1)])
		popup.update = true
	}
	
	listy += (36 + 8)
	
	// Draw layers
	var listystart, listh, insertpos;
	listystart = listy
	listh = 48 * 6
	insertpos = popup.layer_move
	
	scrollbar_draw(popup.layer_scrollbar, e_scroll.VERTICAL, dx + listw - 12, listy, listh, (ds_list_size(popup.pattern_list_edit) + 1) * 48)
	
	if (popup.layer_scrollbar.needed)
	{
		listw -= 16
		listy -= popup.layer_scrollbar.value
		
		window_scroll_focus = string(popup.layer_scrollbar)
	}
	
	clip_begin(dx, listystart, listw, listh)
	
	// Top layer
	if (mouse_y < listy && popup.layer_move != null)
	{
		insertpos = ds_list_size(popup.pattern_list_edit)
		draw_box(dx, listy, listw, 48, false, c_level_bottom, 1)
		listy += 48
	}
	
	for (var i = ds_list_size(popup.pattern_list_edit) - 1; i >= 0; i--)
	{
		// Skip moving layer
		if (popup.layer_move != null && popup.layer_move = i)
			continue
		
		if ((listy < listystart + listh) && (listy + 48 > listystart))
		{
			if (popup.layer_move = null)
			{
				popup_pattern_editor_draw_layer(dx, listy, listw, 48, i, false)
			}
			else
			{
				if (mouse_y >= listy && mouse_y <= listy + 48)
				{
					if (mouse_y >= listy)
					{
						insertpos = i + 1
						draw_box(dx, listy, listw, 48, false, c_level_bottom, 1)
						
						listy += 48
						
						popup_pattern_editor_draw_layer(dx, listy, listw, 48, i, false)
						listy += 48
						
						continue
					}
				}
				else
					popup_pattern_editor_draw_layer(dx, listy, listw, 48, i, false)
			}
		}
		
		listy += 48
	}
	
	// Bottom layer
	if (mouse_y >= listy && popup.layer_move != null)
	{
		insertpos = 0
		draw_box(dx, listy, listw, 48, false, c_level_bottom, 1)
		listy += 48
	}
	
	if ((listy < listystart + listh) && (listy + 48 > listystart))
		popup_pattern_editor_draw_layer(dx, listy, listw, 48, -1, true)
	
	clip_end()
	
	dy += 325 + 8
	
	draw_set_font(font_button)
	var buttonx = string_width(text_get("patterneditordone")) + button_padding;
	
	// Done
	tab_control_button_label()
	if (draw_button_label("patterneditordone", dx_start + dw - buttonx, dy))
	{
		if (popup.pattern_edit.object_index = obj_bench_settings)
		{
			popup.pattern_edit.pattern_pattern_list = ds_list_create_array(popup.pattern_list_edit)
			popup.pattern_edit.pattern_color_list = ds_list_create_array(popup.pattern_color_list_edit)
			popup.pattern_edit.pattern_base_color = popup.pattern_edit_preview.pattern_base_color
			
			array_add(pattern_update, popup.pattern_edit)
			
			bench_settings.preview.update = true
		}
		else if (popup.pattern_edit = temp_edit)
			action_lib_model_pattern(popup.pattern_edit_preview.pattern_base_color, ds_list_create_array(popup.pattern_list_edit), ds_list_create_array(popup.pattern_color_list_edit))
		
		instance_destroy(popup.pattern_edit_preview, false)
		popup.pattern_edit_preview = null
		
		popup_close()
	}
	
	buttonx += 12 + (string_width(text_get("patterneditorcancel")) + button_padding)
	
	// Cancel
	if (draw_button_label("patterneditorcancel", dx_start + dw - buttonx, dy, null, null, e_button.SECONDARY))
	{
		array_add(pattern_update, popup.pattern_edit)
		
		instance_destroy(popup.pattern_edit_preview, false)
		popup.pattern_edit_preview = null
		
		popup_close()
	}
	tab_next()
	
	if (popup.layer_remove != null)
	{
		ds_list_delete(popup.pattern_list_edit, popup.layer_remove)
		ds_list_delete(popup.pattern_color_list_edit, popup.layer_remove)
		
		popup.layer_remove = null
		popup.update = true
	}
	
	if (popup.update)
	{
		if (popup.pattern_edit_preview.pattern_skin)
			sprite_delete(popup.pattern_edit_preview.pattern_skin)
		
		popup.pattern_edit_preview.pattern_skin = minecraft_update_pattern_generate(popup.pattern_edit_preview.model_name, popup.pattern_edit_preview.pattern_base_color, ds_list_create_array(popup.pattern_list_edit), ds_list_create_array(popup.pattern_color_list_edit))
		
		popup.update = false
	}
	
	// Draw moving layer
	if (popup.layer_move != null)
	{
		content_x = 0
		content_y = 0
		content_width = window_width
		content_height = window_height
		
		mouse_cursor = cr_size_all
		
		draw_dropshadow(mouse_x + popup.layer_move_x, mouse_y + popup.layer_move_y, listw, 48, c_black, 1)
		draw_box(mouse_x + popup.layer_move_x, mouse_y + popup.layer_move_y, listw, 48, false, c_level_middle, 1)
		popup_pattern_editor_draw_layer(mouse_x + popup.layer_move_x, mouse_y + popup.layer_move_y, listw, 48, popup.layer_move, false)
		
		// Insert layer
		if (mouse_left_released)
		{
			if (insertpos != popup.layer_move)
			{
				// Insert value
				ds_list_insert(popup.pattern_list_edit, insertpos, popup.pattern_list_edit[|popup.layer_move])
				ds_list_insert(popup.pattern_color_list_edit, insertpos, popup.pattern_color_list_edit[|popup.layer_move])
				
				// Delete old position
				var pos = popup.layer_move;
				
				if (insertpos <= popup.layer_move)
					pos++
				
				ds_list_delete(popup.pattern_list_edit, pos)
				ds_list_delete(popup.pattern_color_list_edit, pos)
			}
			
			popup.layer_move = null
			popup.update = true
			window_busy = "popup" + popup.name
		}
		
		if (mouse_y < listystart)
			popup.layer_scrollbar.value_goal -= 30
		else if (mouse_y > listystart + listh)
			popup.layer_scrollbar.value_goal += 30
	}
}
