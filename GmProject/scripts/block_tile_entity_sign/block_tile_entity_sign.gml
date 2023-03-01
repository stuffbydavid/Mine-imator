/// block_tile_entity_sign(map)
/// @arg map

function block_tile_entity_sign(map)
{
	var text, colorname, color;
	text = ""
	colorname = value_get_string(map[?"Color"], "black")
	color = minecraft_color_list[|ds_list_find_index(minecraft_color_name_list, colorname)]
	
	for (var i = 0; i < 4; i++)
	{
		var line = map[?"Text" + string(i + 1)];
		if (!is_string(line))
			return 0
		
		var textmap = json_decode(line);
		if (ds_map_valid(textmap))
		{
			var linemap = textmap;
			if (ds_list_valid(textmap[?"extra"]) && ds_list_size(textmap[?"extra"]) > 0)
			{
				var extramap = ds_list_find_value(textmap[?"extra"], 0);
				if (ds_map_valid(extramap) && is_string(extramap[?"text"]))
					linemap = extramap;
			}
			
			if (is_string(linemap[?"text"]))
				line = linemap[?"text"]
			
			ds_map_destroy(textmap)
		}
		
		if (line = "")
			line = " "
		
		if (i > 0)
			text += "\n"
		text += line
	}
	
	mc_builder.block_text_map[?build_pos] = text
	mc_builder.block_text_color_map[?build_pos] = color
}
