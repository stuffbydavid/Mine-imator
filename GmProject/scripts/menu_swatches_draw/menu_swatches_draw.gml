/// menu_swatches_draw()

function menu_swatches_draw()
{
	var dystart = dy;
	
	dx += 8
	dy += 8
	
	for (var s = 0; s < array_length(minecraft_swatch_array); s++)
	{
		var swatch = minecraft_swatch_array[s];
		
		dy += 14
		draw_label(text_get("swatch" + swatch.name), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
		dy += 9
		
		var xx;
		xx = dx
		
		for (var c = 0; c < array_length(swatch.colors); c++)
		{
			if (draw_button_swatch(xx, dy, 20, 20, "swatch" + swatch.name + swatch.color_names[c], swatch.colors[c]))
			{
				if (context_menu_current.name = "contextmenuswatchset")
					list_item_script = action_value_set_color
				else
					list_item_script = action_value_mix_color
				
				list_item_script_value = swatch.colors[c]
				
				context_menu_close()
				app_mouse_clear()
				window_busy = context_menu_busy_prev
				
				return true
			}
			
			xx += 24
			
			if ((c mod 8) = 7 && (c != array_length(swatch.colors) - 1))
			{
				dy += 24
				xx = dx
			}
		}
		
		dy += 24
	}
	
	dy += 8
	
	context_menu_current.level_height = (dy - dystart)
}