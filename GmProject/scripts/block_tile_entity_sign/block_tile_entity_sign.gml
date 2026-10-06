/// block_tile_entity_sign(map)
/// @arg map

function block_tile_entity_sign_text(map)
{
	var messagemap = value_get_array(map[?"messages"], "")
	var text = "";
	
	for (var i = 0; i < 4; i++)
	{
		var line = "";
		if (i < array_length(messagemap))
			line = block_tile_entity_sign_component(messagemap[i])
		
		if (line = "")
			line = " "
		
		if (i > 0)
			text += "\n"
		text += line
	}
	
	return text;
}

/// block_tile_entity_sign_component(value)
/// @arg value
/// @desc Returns the plain text of a text component. Sign messages are JSON strings in 1.20-1.21.4,
///		  and text components stored as NBT (strings, compounds or lists) since 1.21.5.

function block_tile_entity_sign_component(value)
{
	var str, first, json;
	str = ""
	
	// Text component stored as NBT
	if (ds_map_valid(value))
	{
		if (is_string(value[?"text"]))
			str = value[?"text"]
		else if (is_string(value[?""])) // Element of a list with mixed types
			str = value[?""]
		
		if (ds_list_valid(value[?"extra"]))
			str += block_tile_entity_sign_component(value[?"extra"])
		
		return str
	}
	
	if (ds_list_valid(value))
	{
		for (var e = 0; e < ds_list_size(value); e++)
			str += block_tile_entity_sign_component(value[|e])
		return str
	}
	
	if (!is_string(value))
		return ""
	
	// JSON text (1.20-1.21.4)
	first = string_char_at(value, 1)
	if (first = "{" || first = "[")
	{
		json = json_decode("{\"text\":\"\",\"extra\":[" + value + "]}")
		if (ds_map_valid(json))
		{
			str = block_tile_entity_sign_component(json)
			ds_map_destroy(json)
			return str
		}
	}
	
	// JSON string literal
	if (first = "\"" && string_length(value) >= 2 && string_char_at(value, string_length(value)) = "\"")
		return string_copy(value, 2, string_length(value) - 2)
	
	// Plain text (1.21.5+)
	return value
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