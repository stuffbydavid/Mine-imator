function block_tile_entity_sign(map)
{
	if (!block_current.timeline || block_current.tl_type != "sign")
		return 0

	var prevtext, frontmap, backmap, text, colorname, color, glowcolor, glowing;
	prevtext = (!is_undefined(mc_builder.block_text_front_map[?build_pos_index]) || !is_undefined(mc_builder.block_text_back_map[?build_pos_index]))
	ds_map_delete(mc_builder.block_text_front_map, build_pos_index)
	ds_map_delete(mc_builder.block_text_back_map, build_pos_index)

	frontmap = map[?"front_text"]
	backmap = map[?"back_text"]
	
	// 1.20+
	if (ds_map_valid(frontmap))
	{
		// Front
		text = block_tile_entity_sign_text(frontmap)
		if (string_replace_all(string_remove_newline(text), " ", "") != "")
		{
			colorname = value_get_string(frontmap[?"color"], "black")
			glowing = value_get_real(frontmap[?"has_glowing_text"], 0)
			mc_builder.block_text_front_color_map[?build_pos_index] = (glowing ? minecraft_get_color("text_glow:" + colorname) : minecraft_get_color("dye:" + colorname))
			mc_builder.block_text_front_glow_color_map[?build_pos_index] = minecraft_get_color("text_glow:outline_" + colorname)
			mc_builder.block_text_front_glowing_map[?build_pos_index] = glowing
			mc_builder.block_text_front_map[?build_pos_index] = text
		}
		
		// Back
		if (ds_map_valid(backmap))
		{
			text = block_tile_entity_sign_text(backmap)
			if (string_replace_all(string_remove_newline(text), " ", "") != "")
			{
				colorname = value_get_string(backmap[?"color"], "black")
				glowing = value_get_real(backmap[?"has_glowing_text"], 0)
				mc_builder.block_text_back_color_map[?build_pos_index] = (glowing ? minecraft_get_color("text_glow:" + colorname) : minecraft_get_color("dye:" + colorname))
				mc_builder.block_text_back_glow_color_map[?build_pos_index] = minecraft_get_color("text_glow:outline_" + colorname)
				mc_builder.block_text_back_glowing_map[?build_pos_index] = glowing
				mc_builder.block_text_back_map[?build_pos_index] = text
			}
		}
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
			{
				text = ""
				break
			}
			
			line = block_tile_entity_sign_component(line, true)
			
			if (line = "")
				line = " "
			
			if (i > 0)
				text += "\n"
			text += line
		}
		
		if (string_replace_all(string_remove_newline(text), " ", "") != "")
		{
			mc_builder.block_text_front_map[?build_pos_index] = text
			mc_builder.block_text_front_color_map[?build_pos_index] = color
			mc_builder.block_text_front_glow_color_map[?build_pos_index] = glowcolor
			mc_builder.block_text_front_glowing_map[?build_pos_index] = glowing
		}
	}

	var hastext = (!is_undefined(mc_builder.block_text_front_map[?build_pos_index]) || !is_undefined(mc_builder.block_text_back_map[?build_pos_index]));
	if (hastext != prevtext)
	{
		var count = value_get_real(mc_builder.block_tl_count_map[?"sign"], 0) + (hastext ? 1 : -1);
		if (count > 0)
			mc_builder.block_tl_count_map[?"sign"] = count
		else
			ds_map_delete(mc_builder.block_tl_count_map, "sign")

		mc_builder.sch_timeline_amount += (hastext ? 1 : -1)
	}
}
