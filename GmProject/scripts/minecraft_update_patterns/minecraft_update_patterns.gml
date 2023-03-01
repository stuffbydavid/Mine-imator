/// minecraft_update_patterns()

function minecraft_update_patterns()
{
	// Update pattern designs for templates
	if (pattern_update != null && window_busy != "popup" + popup_loading.name)
	{
		var obj = pattern_update;
		
		if (is_array(pattern_update))
		{
			for (var i = 0; i < array_length(pattern_update); i++)
			{
				obj = pattern_update[i]
				
				with (obj)
				{
					if (sprite_exists(pattern_skin))
						sprite_delete(pattern_skin)
					
					var res;
					with (obj)
						res = temp_get_model_texobj(null)
					
					pattern_skin = minecraft_update_pattern_generate(model_name, pattern_base_color, pattern_pattern_list, pattern_color_list, res)
					
					if (obj = temp_edit)
						app.lib_preview.update = true
				}
			}
		}
		else
		{
			with (obj)
			{
				if (sprite_exists(pattern_skin))
					sprite_delete(pattern_skin)
				
				var res;
				with (obj)
					res = temp_get_model_texobj(null)
				
				pattern_skin = minecraft_update_pattern_generate(model_name, pattern_base_color, pattern_pattern_list, pattern_color_list, res)
				
				if (obj = temp_edit)
					app.lib_preview.update = true
			}
		}
		
		pattern_update = array()
	}
}
