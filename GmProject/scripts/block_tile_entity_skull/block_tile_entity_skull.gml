/// block_tile_entity_head(map)
/// @arg map

function block_tile_entity_skull(map)
{
	var mapname, ownerid, texlist, texvalue, texurl;
	texvalue = ""
	
	// 1.20.5+ profile with a list of properties
	if (ds_map_valid(map[?"profile"]))
	{
		texlist = ds_map_find_value(map[?"profile"], "properties")
		if (!ds_list_valid(texlist))
			return 0
		
		for (var i = 0; i < ds_list_size(texlist); i++)
		{
			var prop = texlist[|i];
			if (ds_map_valid(prop) && value_get_string(prop[?"name"], "") = "textures")
				texvalue = base64_decode(value_get_string(prop[?"value"], ""))
		}
		
		if (texvalue = "")
			return 0
	}
	else
	{
		mapname = "Owner"
		if (!ds_map_valid(map[?mapname]))
		{
			mapname = "SkullOwner"
			if (!ds_map_valid(map[?mapname]))
				return 0
		}
		
		// Access owner properties and get texture info
		map = map[?mapname]
		map = map[?"Properties"]
		
		if (!ds_map_valid(map))
			return 0
		
		// "textures" is a list with one(?) index
		texlist = map[?"textures"]
		
		if (!ds_list_valid(texlist))
			return 0
		
		// Access first index, should be a JSON object
		map = texlist[|0]
		
		// Decode value (base64)
		texvalue = base64_decode(map[?"Value"])
	}
	
	// Decode string into JSON, should contain 2 objects and a URL value
	map = json_decode(texvalue)
	if (!ds_map_valid(map))
		return 0
	
	if (!ds_map_valid(map[?"textures"]))
		return 0
	
	map = map[?"textures"]
	map = map[?"SKIN"]
	if (!ds_map_valid(map) || !is_string(map[?"url"]))
		return 0
	
	texurl = map[?"url"]
	
	ownerid = filename_change_ext(filename_name(texurl), "")
	
	mc_builder.block_skull_map[?build_pos] = ownerid
	
	if (ds_map_find_value(mc_builder.block_skull_texture_map, ownerid) = undefined)
		mc_builder.block_skull_texture_map[?ownerid] = texurl
}
