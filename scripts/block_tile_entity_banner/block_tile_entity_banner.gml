/// block_tile_entity_banner(map)
/// @arg map

var map, patterns;
var patternlist, patterncolorlist;
map = argument0
patterns = map[?"Patterns"]

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
		pattern = value_get_string(patternmap[?"Pattern"], minecraft_banner_pattern_short_list[|1])
		color = value_get_real(patternmap[?"Color"], 0)
		patternindex = ds_list_find_index(minecraft_banner_pattern_short_list, pattern)

		array_add(patternlist, minecraft_banner_pattern_list[|patternindex])
		array_add(patterncolorlist, minecraft_color_list[|color])
	}
}

var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
var colorindex = ds_list_find_index(minecraft_color_name_list, block_get_state_id_value(block_current, block_state_id_current, "color"));

block_banner_color_map[?ind] = minecraft_color_list[|colorindex]
block_banner_patterns_map[?ind] = patternlist
block_banner_pattern_colors_map[?ind] = patterncolorlist
