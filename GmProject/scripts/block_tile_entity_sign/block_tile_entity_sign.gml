/// block_tile_entity_sign(map)
/// @arg map

function block_tile_entity_sign_text(map)
{
	var messagemap = value_get_array(map[?"messages"], "")
	var text = "";
	
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
	
	return text;
}

function block_tile_entity_sign(map)
{
	var frontmap = map[?"front_text"];
	var backmap = map[?"back_text"];
	
	var text, colorname, color, glowcolor, glowing;
	
	// 1.20+
	if (ds_map_valid(frontmap))
	{
		// Front
		colorname = value_get_string(frontmap[?"color"], "black")
		glowing = value_get_real(frontmap[?"has_glowing_text"], 0)
		mc_builder.block_text_front_color_map[?build_pos] = (glowing ? minecraft_get_color("text_glow:" + colorname) : minecraft_get_color("dye:" + colorname))
		mc_builder.block_text_front_glow_color_map[?build_pos] = minecraft_get_color("text_glow:outline_" + colorname)
		mc_builder.block_text_front_glowing_map[?build_pos] = glowing
		mc_builder.block_text_front_map[?build_pos] = block_tile_entity_sign_text(frontmap)
		
		// Back
		colorname = value_get_string(backmap[?"color"], "black")
		glowing = value_get_real(backmap[?"has_glowing_text"], 0)
		mc_builder.block_text_back_color_map[?build_pos] = (glowing ? minecraft_get_color("text_glow:" + colorname) : minecraft_get_color("dye:" + colorname))
		mc_builder.block_text_back_glow_color_map[?build_pos] = minecraft_get_color("text_glow:outline_" + colorname)
		mc_builder.block_text_back_glowing_map[?build_pos] = glowing
		mc_builder.block_text_back_map[?build_pos] = block_tile_entity_sign_text(backmap)
	}
	else // Use legacy format if detected
	{
		colorname = value_get_string(map[?"Color"], "black")
		glowing = value_get_real(map[?"GlowingText"], 0)
		color = (glowing ? minecraft_get_color("text_glow:" + colorname) : minecraft_get_color("dye:" + colorname))
		glowcolor = minecraft_get_color("text_glow:outline_" + colorname)
		text = ""
		
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
		
		mc_builder.block_text_front_map[?build_pos] = text
		mc_builder.block_text_front_color_map[?build_pos] = color
		mc_builder.block_text_front_glow_color_map[?build_pos] = glowcolor
		mc_builder.block_text_front_glowing_map[?build_pos] = glowing
	}
}