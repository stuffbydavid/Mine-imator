/// block_tile_entity_banner(map)
/// @arg map

function block_tile_entity_banner(map)
{
	var patterns, base, legacy;
	var patternlist, patterncolorlist;
	
	if (ds_list_valid(map[?"patterns"])) // 1.20.5+ format
	{
		patterns = map[?"patterns"]
		patternlist = array()
		patterncolorlist = array()
		
		// Base color
		var color = c_white;
		var col = block_get_state_id_value(block_current, block_state_id_current, "color");
		if (!is_undefined(col))
			color = minecraft_get_color("dye:" + col)
		
		// Patterns
		if (ds_list_valid(patterns))
		{
			for (var i = 0; i < ds_list_size(patterns); i++)
			{
				var patternmap = patterns[|i];
			
				if (!ds_map_valid(patternmap))
					continue
				
				var pattern, colorname, patternindex;
				pattern = string_replace(value_get_string(patternmap[?"pattern"], minecraft_pattern_list[|1]), "minecraft:", "")
				colorname = value_get_string(patternmap[?"color"], "black")
				patternindex = ds_list_find_index(minecraft_pattern_list, pattern)
				
				if (patternindex = -1)
					continue
				
				array_add(patternlist, minecraft_pattern_list[|patternindex])
				array_add(patterncolorlist, minecraft_get_color("dye:" + colorname))
			}
		}
		
		mc_builder.block_banner_color_map[?build_pos] = color
		mc_builder.block_banner_patterns_map[?build_pos] = patternlist
		mc_builder.block_banner_pattern_colors_map[?build_pos] = patterncolorlist
	}
	else // Pre-1.20.5 format
	{
		patterns = map[?"Patterns"]
		
		// Pre-1.13 Base value
		if (ds_map_exists(map, "Base"))
		{
			base = map[?"Base"]
			legacy = true
		}
		else
		{
			base = null
			legacy = false
		}
	
		patternlist = array()
		patterncolorlist = array()
	
		if (ds_list_valid(patterns))
		{
			for (var i = 0; i < ds_list_size(patterns); i++)
			{
				var patternmap = patterns[|i];
			
				if (!ds_map_valid(patternmap))
					continue
			
				var pattern, color, patternindex;
				pattern = value_get_string(patternmap[?"Pattern"], minecraft_pattern_short_list[|1])
				color = value_get_real(patternmap[?"Color"], 0)
				patternindex = ds_list_find_index(minecraft_pattern_short_list, pattern)
			
				// Flip color index if legacy
				if (legacy)
					color = (minecraft_swatch_dyes.size - 1) - color
			
				array_add(patternlist, minecraft_pattern_list[|patternindex])
				array_add(patterncolorlist, minecraft_swatch_dyes.colors[color])
			}
		}
	
		// Override banner color if legacy
		var colorindex = 0;
		var color = c_white;
	
		if (legacy)
		{
			colorindex = (minecraft_swatch_dyes.size - 1) - base
			color = minecraft_swatch_dyes.colors[colorindex]
		}
		else
		{
			var col = block_get_state_id_value(block_current, block_state_id_current, "color");
			if (!is_undefined(col))
				color = minecraft_swatch_dyes.map[?col]
		}
		
		mc_builder.block_banner_color_map[?build_pos] = color
		mc_builder.block_banner_patterns_map[?build_pos] = patternlist
		mc_builder.block_banner_pattern_colors_map[?build_pos] = patterncolorlist
	}
}
