/// popup_pattern_editor_edit_layer()

function popup_pattern_editor_edit_layer()
{
	draw_label(text_get("patterneditorcolors"), dx, dy + 4, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
	dy += 18
	
	var colorsx, size;
	colorsx = dx
	size = ((popup_pattern_editor.layer_edit != -1) ? 16 : 8)
	
	for (var c = 0; c < array_length(minecraft_swatch_dyes.colors); c++)
	{
		if (draw_button_swatch(colorsx, dy, 20, 20, "swatch" + minecraft_swatch_dyes.name + minecraft_swatch_dyes.color_names[c], minecraft_swatch_dyes.colors[c]))
		{
			if (popup_pattern_editor.layer_edit = -1)
				popup_pattern_editor.pattern_edit_preview.pattern_base_color = minecraft_swatch_dyes.colors[c]
			else
				popup_pattern_editor.pattern_color_list_edit[|popup_pattern_editor.layer_edit] = minecraft_swatch_dyes.colors[c]
			
			popup_pattern_editor.update = true
		}
		
		colorsx += 24
		
		if (((c mod size) = (size - 1)) && (c != array_length(minecraft_swatch_dyes.colors) - 1))
		{
			dy += 24
			colorsx = dx
		}
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
			var active = (popup_pattern_editor.pattern_list_edit[|popup_pattern_editor.layer_edit] = minecraft_pattern_list[|p]);
			if (draw_button_icon("patterneditorpatterns" + string(p), patternsx, dy, 20, 40, active, null, null, false, "patterneditorpatterns" + minecraft_pattern_list[|p], popup_pattern_editor.pattern_sprites[p]))
			{
				popup_pattern_editor.pattern_list_edit[|popup_pattern_editor.layer_edit] = minecraft_pattern_list[|p]
				popup_pattern_editor.update = true
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
	
	settings_menu_w = 24 + ((24 * size) - 4)
}
