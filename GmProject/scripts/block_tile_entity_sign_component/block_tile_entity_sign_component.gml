/// @desc Parse a legacy sign tile entity text component.

function block_tile_entity_sign_component(component, parsejson = false)
{
	var result;

	if (is_string(component))
	{
		if (parsejson && string_length(component) > 0)
		{
			var first = string_char_at(component, 1)
			if (first = "{" || first = "[" || first = "\"")
			{
				var parsed = json_decode("{\"component\":" + component + "}")
				if (ds_map_valid(parsed))
				{
					result = block_tile_entity_sign_component(parsed[?"component"])
					ds_map_destroy(parsed)
					
					return result
				}
			}
		}

		return component
	}

	if (ds_list_valid(component))
	{
		result = ""
		for (var i = 0; i < ds_list_size(component); i++)
			result += block_tile_entity_sign_component(component[|i])

		return result
	}

	if (!ds_map_valid(component))
		return ""

	// NBT wraps primitive entries in lists with an empty key
	var wrapped = component[?""]
	if (!is_undefined(wrapped))
		return block_tile_entity_sign_component(wrapped)

	if (is_string(component[?"text"]))
		result = component[?"text"]
	else if (is_string(component[?"default"]))
		result = value_get_string(component[?"default"])
	else
		result = value_get_string(component[?"fallback"], value_get_string(component[?"translate"]))

	var extra = component[?"extra"]
	if (ds_list_valid(extra))
	{
		for (var i = 0; i < ds_list_size(extra); i++)
			result += block_tile_entity_sign_component(extra[|i])
	}

	return result
}
