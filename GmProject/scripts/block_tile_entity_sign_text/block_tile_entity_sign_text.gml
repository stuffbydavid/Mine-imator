/// @desc Parse legacy sign text contents.

function block_tile_entity_sign_text(map)
{
	var messages, text;
	messages = map[?"messages"]
	
	if (!ds_list_valid(messages))
		return ""

	text = ""

	for (var i = 0; i < 4; i++)
	{
		var line;
		line = ""

		if (i < ds_list_size(messages))
			line = block_tile_entity_sign_component(messages[|i], true)

		if (line = "")
			line = " "

		if (i > 0)
			text += "\n"
		
		text += line
	}
	
	return text
}
