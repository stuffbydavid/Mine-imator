function block_tile_entity_sign_text(map)
{
	var messagemap = value_get_array(map[?"messages"], "")
	var text = "";
	
	for (var i = 0; i < 4; i++)
	{
		var line = "";
		var textmap = json_decode(messagemap[i]);
			
		if (ds_map_valid(textmap))
		{
			if (is_string(textmap[?"text"]))
				line = textmap[?"text"]
			else if (is_string(textmap[?"default"]))
				line = textmap[?"default"]
				
			ds_map_destroy(textmap)
		}
			
		if (line = "")
			line = " "
			
		if (i > 0)
			text += "\n"
		text += line
	}
	
	return text;
}
