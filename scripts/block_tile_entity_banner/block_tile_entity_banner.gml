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
	
	var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
	
	// Override banner color if legacy
	var colorindex;
	
	if (legacy)
		colorindex = (ds_list_size(minecraft_color_list) - 1) - base
	else
		colorindex = ds_list_find_index(minecraft_color_name_list, block_get_state_id_value(block_current, block_state_id_current, "color"))
	
	block_banner_color_map[?ind] = minecraft_color_list[|colorindex]
	block_banner_patterns_map[?ind] = patternlist
	block_banner_pattern_colors_map[?ind] = patterncolorlist
}
