/// block_tile_entity_head(map)
/// @arg map

function block_tile_entity_skull(map)
{
	var ownerid, texlist, texvalue, texurl;
	
	if (ds_map_valid(map[?"profile"])) // 1.20.5+ format
	{
		// Access owner properties and get texture info
		map = map[?"profile"]
		ownerid = string(map[?"id"])
		
		// "properties" is a list with one(?) index
		texlist = map[?"properties"]
		if (!ds_list_valid(texlist))
			return 0
		
		// Access first index, should be a JSON object
		map = texlist[|0]
		
		// Decode value (base64)
		texvalue = base64_decode(map[?"value"])
		
		// Decode string into JSON, should contain 2 objects and a URL value
		map = json_decode(texvalue)
		if (!ds_map_valid(map))
			return 0
		
		map = map[?"textures"]
		map = map[?"SKIN"]
		texurl = map[?"url"]
		
		ownerid = filename_change_ext(filename_name(texurl), "")
		
		mc_builder.block_skull_map[?build_pos] = ownerid
		
		if (ds_map_find_value(mc_builder.block_skull_texture_map, ownerid) = undefined)
			mc_builder.block_skull_texture_map[?ownerid] = texurl
	}
	else // Pre-1.20.5 format
	{
		var mapname = "Owner"
		if (!ds_map_valid(map[?mapname]))
		{
			mapname = "SkullOwner"
			if (!ds_map_valid(map[?mapname]))
				return 0
		}
		
		// Access owner properties and get texture info
		map = map[?mapname]
		ownerid = string(map[?"Id"]) // Newer versions save Id differently, load as a string and replace with name? not perfect tho
		
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
		
		// Decode string into JSON, should contain 2 objects and a URL value
		map = json_decode(texvalue)
		if (!ds_map_valid(map))
			return 0
		
		if (!ds_map_valid(map[?"textures"]))
			return 0
		
		map = map[?"textures"]
		map = map[?"SKIN"]
		texurl = map[?"url"]
		
		ownerid = filename_change_ext(filename_name(texurl), "")
		
		mc_builder.block_skull_map[?build_pos] = ownerid
		
		if (ds_map_find_value(mc_builder.block_skull_texture_map, ownerid) = undefined)
			mc_builder.block_skull_texture_map[?ownerid] = texurl
	}
}
