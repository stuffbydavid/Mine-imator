function popup_pattern_editor_draw()
{
	if (popup_current.update)
	{
		if (popup_current.pattern_edit_preview.pattern_skin)
			texture_free(popup_current.pattern_edit_preview.pattern_skin)
		
		var patternsarr, colorsarr;
		patternsarr = ds_list_create_array(popup_current.pattern_list_edit)
		colorsarr = ds_list_create_array(popup_current.pattern_color_list_edit)
		popup_current.pattern_edit_preview.pattern_skin = minecraft_update_pattern_generate(popup_current.pattern_edit_preview.model_name, popup_current.pattern_edit_preview.pattern_base_color, patternsarr, colorsarr)
		popup_current.update = false
		popup_current.preview.update = true
	}
	
	dx_start = dx
	
	// Model preview
	setting_wind_enable = false
	preview_draw(popup_current.preview, dx, dy, 200, 332)
	setting_wind_enable = true
	
	dx += 200 + 8
	
	draw_separator_vertical(dx, dy + 4, 332 - 8)
	dx += 8
	
	var listy, listw;
	listy = dy
	listw = dw - (dx - dx_start)
	
	// Add layer
	if (draw_button_label("pattern_editor/add_layer", dx, dy, listw, icons.PLUS, e_button.SECONDARY))
	{
		var pt = 1 + irandom(ds_list_size(minecraft_pattern_list) - 2);
		ds_list_add(popup_current.pattern_list_edit, minecraft_pattern_list[|pt])
		ds_list_add(popup_current.pattern_color_list_edit, minecraft_swatch_dyes.colors[irandom(array_length(minecraft_swatch_dyes.colors) - 1)])
		popup_current.update = true
	}
	
	listy += (36 + 8)
	
	// Draw layers
	var listystart, listh, insertpos;
	listystart = listy
	listh = 48 * 6
	insertpos = popup_current.layer_move
	
	scrollbar_draw(popup_current.layer_scrollbar, e_scroll.VERTICAL, dx + listw - 12, listy, listh, (ds_list_size(popup_current.pattern_list_edit) + 1) * 48)
	
	if (popup_current.layer_scrollbar.needed)
	{
		listw -= 16
		listy -= popup_current.layer_scrollbar.value
		
		window_scroll_focus = string(popup_current.layer_scrollbar)
	}
	
	clip_begin(dx, listystart, listw, listh)
	
	// Top layer
	if (mouse_y < listy && popup_current.layer_move != null)
	{
		insertpos = ds_list_size(popup_current.pattern_list_edit)
		draw_box(dx, listy, listw, 48, false, c_level_bottom, 1)
		listy += 48
	}
	
	for (var i = ds_list_size(popup_current.pattern_list_edit) - 1; i >= 0; i--)
	{
		// Skip moving layer
		if (popup_current.layer_move != null && popup_current.layer_move = i)
			continue
		
		if ((listy < listystart + listh) && (listy + 48 > listystart))
		{
			if (popup_current.layer_move = null)
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
	if (mouse_y >= listy && popup_current.layer_move != null)
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
	var buttonx = string_width(text_get("pattern_editor/done")) + button_padding;
	
	// Done
	tab_control_button_label()
	if (draw_button_label("pattern_editor/done", dx_start + dw - buttonx, dy))
	{
		if (popup_current.pattern_edit.object_index = obj_bench_settings)
		{
			popup_current.pattern_edit.pattern_pattern_list = ds_list_create_array(popup_current.pattern_list_edit)
			popup_current.pattern_edit.pattern_color_list = ds_list_create_array(popup_current.pattern_color_list_edit)
			popup_current.pattern_edit.pattern_base_color = popup_current.pattern_edit_preview.pattern_base_color
			
			array_add(pattern_update, popup_current.pattern_edit)
			
			bench_settings.preview.update = true
		}
		else
			action_lib_model_pattern(popup_current.pattern_edit_preview.pattern_base_color, ds_list_create_array(popup_current.pattern_list_edit), ds_list_create_array(popup_current.pattern_color_list_edit))
		
		if (sprite_exists(popup_current.pattern_edit_preview.pattern_skin))
			texture_free(popup_current.pattern_edit_preview.pattern_skin)
		
		instance_destroy(popup_current.pattern_edit_preview, false)
		popup_current.pattern_edit_preview = null
		
		popup_close()
	}
	
	buttonx += 12 + (string_width(text_get("pattern_editor/cancel")) + button_padding)
	
	// Cancel
	if (draw_button_label("pattern_editor/cancel", dx_start + dw - buttonx, dy, null, null, e_button.SECONDARY))
	{
		array_add(pattern_update, popup_current.pattern_edit)
		
		if (sprite_exists(popup_current.pattern_edit_preview.pattern_skin))
			texture_free(popup_current.pattern_edit_preview.pattern_skin)
		
		instance_destroy(popup_current.pattern_edit_preview, false)
		popup_current.pattern_edit_preview = null
		
		popup_close()
	}
	tab_next()
	
	if (popup_current.layer_remove != null)
	{
		ds_list_delete(popup_current.pattern_list_edit, popup_current.layer_remove)
		ds_list_delete(popup_current.pattern_color_list_edit, popup_current.layer_remove)
		
		popup_current.layer_remove = null
		popup_current.update = true
	}
	
	// Draw moving layer
	if (popup_current.layer_move != null)
	{
		content_x = 0
		content_y = 0
		content_width = window_width
		content_height = window_height
		
		mouse_cursor = cr_size_all
		
		draw_dropshadow(mouse_x + popup_current.layer_move_x, mouse_y + popup_current.layer_move_y, listw, 48, c_black, 1)
		draw_box(mouse_x + popup_current.layer_move_x, mouse_y + popup_current.layer_move_y, listw, 48, false, c_level_middle, 1)
		popup_pattern_editor_draw_layer(mouse_x + popup_current.layer_move_x, mouse_y + popup_current.layer_move_y, listw, 48, popup_current.layer_move, false)
		
		// Insert layer
		if (mouse_left_released)
		{
			if (insertpos != popup_current.layer_move)
			{
				// Insert value
				ds_list_insert(popup_current.pattern_list_edit, insertpos, popup_current.pattern_list_edit[|popup_current.layer_move])
				ds_list_insert(popup_current.pattern_color_list_edit, insertpos, popup_current.pattern_color_list_edit[|popup_current.layer_move])
				
				// Delete old position
				var pos = popup_current.layer_move;
				
				if (insertpos <= popup_current.layer_move)
					pos++
				
				ds_list_delete(popup_current.pattern_list_edit, pos)
				ds_list_delete(popup_current.pattern_color_list_edit, pos)
			}
			
			popup_current.layer_move = null
			popup_current.update = true
			window_busy = "popup/" + popup_current.name
		}
		
		if (mouse_y < listystart)
			popup_current.layer_scrollbar.value_goal -= 30
		else if (mouse_y > listystart + listh)
			popup_current.layer_scrollbar.value_goal += 30
	}
}
