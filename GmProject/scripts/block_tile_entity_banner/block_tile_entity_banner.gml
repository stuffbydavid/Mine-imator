/// block_tile_entity_banner(map)
/// @arg map

function block_tile_entity_banner(map)
{
	var patterns, base, legacy;
	var patternlist, patterncolorlist;
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
				color = (ds_list_size(minecraft_color_list) - 1) - color
			
			array_add(patternlist, minecraft_pattern_list[|patternindex])
			array_add(patterncolorlist, minecraft_color_list[|color])
		}
	}
	
	// Override banner color if legacy
	var colorindex = 0;

	if (legacy)
		colorindex = (ds_list_size(minecraft_color_list) - 1) - base
	else
	{
		var color = block_get_state_id_value(block_current, block_state_id_current, "color");
		if (!is_undefined(color))
			colorindex = ds_list_find_index(minecraft_color_name_list, color)
	}
	
	mc_builder.block_banner_color_map[?build_pos] = minecraft_color_list[|colorindex]
	mc_builder.block_banner_patterns_map[?build_pos] = patternlist
	mc_builder.block_banner_pattern_colors_map[?build_pos] = patterncolorlist
}
