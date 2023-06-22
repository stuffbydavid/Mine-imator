/// minecraft_update_armor()

function minecraft_update_armor()
{
	// Update pattern designs for templates
	if (armor_update != null && window_busy != "popup" + popup_loading.name)
	{
		var obj = armor_update;
		
		for (var i = 0; i < array_length(armor_update); i++)
		{
			obj = armor_update[i]
			
			with (obj)
			{
				for (var j = 0; j < 4; j++)
				{
					if (sprite_exists(armor_skin_array[j]))
						sprite_delete(armor_skin_array[j])
				}
				
				var res;
				with (obj)
					res = temp_get_model_texobj(null)
				
				armor_skin_array = minecraft_update_armor_generate(armor_array, res)
				
				if (obj = temp_edit)
					app.lib_preview.update = true
			}
		}
		
		armor_update = []
	}
}

