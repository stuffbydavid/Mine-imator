/// block_tile_entity_sign(map)
/// @arg map

var map, state;
map = argument0
state = block_state_current

for (var i = 0; i < 4; i++)
{
	var text = map[?"Text" + string(i + 1)];
	if (!is_string(text))
		return 0
		
	var textmap = json_decode(text);
	if (ds_map_valid(textmap))
		text= textmap[?"text"]
	
	// Escape = and , in the text
	text = string_replace_all(text, "=", "\\=")
	text = string_replace_all(text, ",", "\\,")
	
	state += ",text" + string(i + 1) + "=" + text
}

array3D_set(block_state, build_pos, state)