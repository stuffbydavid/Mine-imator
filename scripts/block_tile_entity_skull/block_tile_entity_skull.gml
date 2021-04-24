/// block_tile_entity_head(map)
/// @arg map

function block_tile_entity_skull(map)
{
	var ownerid, texlist, texvalue, texurl;
	
	if (!ds_map_valid(map[?"Owner"]))
		return 0
	
	// Access owner properties and get texture info
	map = map[?"Owner"]
	
	ownerid = map[?"Id"]
	map = map[?"Properties"]
	
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
	
	if (!ds_map_valid(map[?"textures"]))
		return 0
	
	map = map[?"textures"]
	map = map[?"SKIN"]
	texurl = map[?"url"]
	
	var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
	
	block_skull_map[?ind] = ownerid
	
	if (ds_map_find_value(block_skull_texture_map, ownerid) = undefined)
		block_skull_texture_map[?ownerid] = texurl
}
