/// minecraft_update_banner()

function minecraft_update_banner()
{
	// Update banner template when resources aren't being loaded
	if (banner_update != null && window_busy != "popup" + popup_loading.name)
	{
		var banner = banner_update;
		
		if (is_array(banner_update))
		{
			for (var i = 0; i < array_length(banner_update); i++)
			{
				banner = banner_update[i]
				
				with (banner)
				{
					if (sprite_exists(banner_skin))
						sprite_delete(banner_skin)
					
					var res;
					with (banner)
						res = temp_get_model_texobj(null)
					
					banner_skin = minecraft_update_banner_generate(banner_base_color, banner_pattern_list, banner_color_list, res)
				}
			}
		}
		else
		{
			with (banner)
			{
				if (sprite_exists(banner_skin))
					sprite_delete(banner_skin)
				
				var res;
				with (banner)
					res = temp_get_model_texobj(null)
				
				banner_skin = minecraft_update_banner_generate(banner_base_color, banner_pattern_list, banner_color_list, res)
			}
		}
		
		banner_update = array()
	}
}
