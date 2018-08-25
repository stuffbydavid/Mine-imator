/// block_tile_entity_sign(map)
/// @arg map

var map, text;
map = argument0
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
			textmap = ds_list_find_value(textmap[?"extra"], 0)
		
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

var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
block_text_map[?ind] = text