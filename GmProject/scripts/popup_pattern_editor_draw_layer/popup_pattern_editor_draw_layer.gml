/// popup_pattern_editor_draw_layer(x, y, width, height, index, base)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg index
/// @arg base

function popup_pattern_editor_draw_layer(xx, yy, width, height, index, base)
{
	var editname, mouseon, dragging, actionx, layerpattern, layercolor;
	
	if (popup_pattern_editor.pattern_edit_preview = null)
		return 0
	
	editname = "patterneditoreditlayer" + string(index)
	mouseon = (app_mouse_box(xx, yy, width, height) || (popup_pattern_editor.layer_edit = index && settings_menu_name = editname))
	dragging = (popup_pattern_editor.layer_move = index)
	layerpattern = (base ? 1 : ds_list_find_index(minecraft_pattern_list, popup_pattern_editor.pattern_list_edit[|index]))
	layercolor = (base ? minecraft_get_color("dye:black") : popup_pattern_editor.pattern_color_list_edit[|index])
	
	// Draw pattern
	if (popup_pattern_editor.pattern_edit_preview != null)
		draw_box(xx + 4, yy + 4, 20, 40, false, popup_pattern_editor.pattern_edit_preview.pattern_base_color, 1)
	
	if (!base)
		draw_sprite_ext(popup_pattern_editor.pattern_sprites[layerpattern], 0, xx + 4, yy + 4, 1 / popup_pattern_editor.res_ratio, 1 / popup_pattern_editor.res_ratio, 0, layercolor, 1)
	
	gpu_set_blendmode_ext(bm_zero, bm_src_color)
	draw_sprite_ext(popup_pattern_editor.pattern_sprites[array_length(popup_pattern_editor.pattern_sprites) - 1], 0, xx + 4, yy + 4, (1 / popup_pattern_editor.res_ratio), (1 / popup_pattern_editor.res_ratio), 0, c_white, 1)
	gpu_set_blendmode(bm_normal)
	
	// Layer name
	var colorname, name;
	
	if (base)
	{
		colorname = ds_map_find_key(minecraft_swatch_dyes.map, popup_pattern_editor.pattern_edit_preview.pattern_base_color)
		name = text_get("patterneditorbase", text_get("swatchdye" + colorname))
	}
	else
	{
		colorname = ds_map_find_key(minecraft_swatch_dyes.map, popup_pattern_editor.pattern_color_list_edit[|index])
		name = text_get("patterneditorlayer", text_get("swatchdye" + colorname), text_get("patterneditorpatterns" + popup_pattern_editor.pattern_list_edit[|index]))
	}
	
	draw_label(name, xx + 32, yy + height/2, fa_left, fa_middle, c_text_main, a_text_main, font_value)
	
	actionx = xx + width - 4
	
	// Drag layer
	if (!base)
	{
		var draghover = app_mouse_box(actionx - 20, yy + height/2 - 14, 20, 28);
		
		if (draghover)
		{
			mouse_cursor = cr_size_all
			
			if (mouse_move > 0 && !dragging)
			{
				popup_pattern_editor.layer_move = index
				popup_pattern_editor.layer_move_x = xx - mouse_x
				popup_pattern_editor.layer_move_y = yy - mouse_y
				window_busy = "patterneditordraglayer"
			}
		}
		
		draw_image(spr_icons, icons.DRAGGER, actionx - 10, yy + height/2, 1, 1, c_text_tertiary, a_text_tertiary)
		
		actionx -= 24
		
		// Remove layer
		if (mouseon && !dragging)
		{
			if (draw_button_icon("patterneditorremovelayer" + string(index), actionx - 24, yy + height/2 - 14, 24, 24, false, icons.DELETE))
				popup_pattern_editor.layer_remove = index
			
			actionx -= 28
		}
	}
	
	// Edit layer
	if (mouseon && !dragging)
	{
		if (draw_button_icon(editname, actionx - 24, yy + height/2 - 14, 24, 24, settings_menu_name = editname, icons.PENCIL))
		{
			menu_settings_set(actionx - 24, yy + height/2 - 14, editname, 24)
			settings_menu_script = popup_pattern_editor_edit_layer
			settings_menu_busy_prev = "popup" + popup.name
			popup_pattern_editor.layer_edit = index
		}
		
		if (settings_menu_name = editname && settings_menu_ani_type != "hide")
			current_microani.active.value = true	
	}
}
