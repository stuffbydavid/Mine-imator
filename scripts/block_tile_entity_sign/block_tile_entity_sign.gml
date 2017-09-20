/// block_tile_entity_sign(map)
/// @arg map

var map, str;
map = argument0
str = ""

for (var i = 0; i < 4; i++)
{
	var text = map[?"Text" + string(i + 1)];
	if (!is_string(text))
		return 0
		
	var textmap = json_decode(text);
	if (ds_map_valid(textmap))
	{
		if (is_string(textmap[?"text"]))
			text = textmap[?"text"]
			
		ds_map_destroy(textmap)
	}
	
	if (i > 0)
		str += "\n"
	
	if (text = "")
		text = " "
	
	str += text
}

// Escape = and , in text
str = string_replace_all(str, "=", "\\=")
str = string_replace_all(str, ",", "\\,")

array3D_set(block_state, build_pos, block_state_current + ",text=" + str)