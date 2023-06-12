/// block_tile_entity_sign(map)
/// @arg map

function block_tile_entity_sign(map)
{
	var frontmap = map[?"front_text"];
	//var backmap = map[?"back_text"]; // gotta figure out how to make it work for both front and back of sign (might need changes outside of this function?), + discuss .midata file changes -mb
	
	var text, colorname, color, glowing;
	text = ""
	
	if (ds_map_valid(frontmap))
	{
		colorname = value_get_string(frontmap[?"color"], "black")
		color = minecraft_color_list[|ds_list_find_index(minecraft_color_name_list, colorname)]
		glowing = value_get_real(frontmap[?"has_glowing_text"], 0)
		
		var messagemap = value_get_array(frontmap[?"messages"], "")
		
		for (var i = 0; i < 4; i++)
		{
			var line = "";
			var textmap = json_decode(messagemap[i]);
			
			if (ds_map_valid(textmap))
			{
				if (is_string(textmap[?"text"]))
					line = textmap[?"text"]
				
				ds_map_destroy(textmap)
			}
			
			if (line = "")
				line = " "
			
			if (i > 0)
				text += "\n"
			text += line
		}
	}
	else // Use legacy format if detected
	{
		colorname = value_get_string(map[?"Color"], "black")
		color = minecraft_color_list[|ds_list_find_index(minecraft_color_name_list, colorname)]
		glowing = value_get_real(map[?"GlowingText"], 0)
		
		for (var i = 0; i < 4; i++)
		{
			var line = map[?"Text" + string(i + 1)];
			if (!is_string(line))
				return 0
			
			var textmap = json_decode(line);
			if (ds_map_valid(textmap))
			{
				if (ds_list_valid(textmap[?"extra"]) && ds_list_size(textmap[?"extra"]) > 0)
				{
					var extramap = ds_list_find_value(textmap[?"extra"], 0);
					if (ds_map_valid(extramap) && is_string(extramap[?"text"]))
						textmap = extramap;
				}
				
				if (is_string(textmap[?"text"]))
					line = textmap[?"text"]
				
				ds_map_destroy(textmap)
			}
			
			if (line = "")
				line = " "
			
			if (i > 0)
				text += "\n"
			text += line
		}
	}
	
	mc_builder.block_text_map[?build_pos] = text
	mc_builder.block_text_color_map[?build_pos] = color
	mc_builder.block_text_glowing_map[?build_pos] = glowing
}