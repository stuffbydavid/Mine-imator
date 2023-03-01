/// popup_pattern_editor_edit_layer()

function popup_pattern_editor_edit_layer()
{
	draw_label(text_get("patterneditorcolors"), dx, dy + 4, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 18
	
	var colorsx;
	colorsx = dx
	
	for (var i = 0; i < 16; i++)
	{
		if (app_mouse_box(colorsx, dy, 20, 20))
		{
			mouse_cursor = cr_handpoint
			
			if (mouse_left_pressed)
			{
				if (popup_pattern_editor.layer_edit = -1)
					popup_pattern_editor.pattern_edit_preview.pattern_base_color = minecraft_color_list[|i]
				else
					popup_pattern_editor.pattern_color_list_edit[|popup_pattern_editor.layer_edit] = minecraft_color_list[|i]
				
				popup_pattern_editor.update = true
			}
		}
		
		draw_box(colorsx, dy, 20, 20, false, minecraft_color_list[|i], 1)
		colorsx += 24
	}
	
	dy += 20 + 8
	
	if (popup_pattern_editor.layer_edit != -1)
	{
		dy += 8
		draw_label(text_get("patterneditorpatterns"), dx, dy + 4, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
		dy += 18
		
		var patternsx, patternsy;
		patternsx = dx
		patternsy = dy
		
		var p = 1;
		for (; p < ds_list_size(minecraft_pattern_list); p++)
		{
			draw_box(patternsx, dy, 20, 40, false, c_level_bottom, 1)
			draw_image(popup_pattern_editor.pattern_sprites[p], 0, patternsx, dy, (1 / popup_pattern_editor.res_ratio), (1 / popup_pattern_editor.res_ratio), c_text_main, a_text_main)
			
			if (app_mouse_box(patternsx, dy, 20, 40))
			{
				mouse_cursor = cr_handpoint
				
				if (mouse_left_pressed)
				{
					popup_pattern_editor.pattern_list_edit[|popup_pattern_editor.layer_edit] = minecraft_pattern_list[|p]
					popup_pattern_editor.update = true
				}
			}
			
			patternsx += 24
			
			if ((p mod 16) = 0)
			{
				patternsx = dx
				dy += 44
			}
		}
		
		if ((p mod 16) != 0)
			dy += 44
		
		dy += 4
	}
	
	settings_menu_w = 24 + ((24 * 16) - 4)
}
