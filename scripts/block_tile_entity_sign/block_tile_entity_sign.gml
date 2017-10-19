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

builder_set(block_text, build_pos_x, build_pos_y, build_pos_z, text)