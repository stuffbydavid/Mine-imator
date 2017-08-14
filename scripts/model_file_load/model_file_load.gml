/// model_load(filename)
/// @arg filename
/// @desc Loads the parts and shapes from the selected filename.

var fname  = argument0;
	
if (!file_exists_lib(fname))
{
	log("Could not find model file", fname)
	return null
}

var json, map;
json = file_text_contents(fname)
map = json_decode(json)
if (map < 0)
{
	log("Could not parse model file", fname)
	return null
}

if (!is_string(map[?"name"]))
{
	log("Missing parameter \"name\"")
	return null
}

if (!is_string(map[?"texture"]))
{
	log("Missing parameter \"texture\"")
	return null
}

if (!is_real(map[?"texture_size"]) || !ds_exists(map[?"texture_size"], ds_type_list))
{
	log("Missing array \"texture_size\"")
	return null
}

if (!is_real(map[?"parts"]) || !ds_exists(map[?"parts"], ds_type_list))
{
	log("Missing array \"parts\"")
	return null
}

with (new(obj_model_file))
{
	// Name
	name = map[?"name"]
	
	// Description (optional)
	if (is_string(map[?"description"]))
		description = map[?"description"]
	else
		description = ""
		
	// Texture
	texture = map[?"texture"]
	
	// Texture size
	var texturesizelist = map[?"texture_size"];
	texture_size = vec2(texturesizelist[|X], texturesizelist[|Y])

	// Player skin
	player_skin = false
	if (is_real(map[?"player_skin"]))
		player_skin = map[?"player_skin"]
	
	// Bounds in default position
	bounds_start = point3D(0, 0, 0)
	bounds_end = point3D(0, 0, 0)
	
	// Read all the parts of the root
	var partlist = map[?"parts"]
	part_amount = ds_list_size(partlist)
	for (var p = 0; p < part_amount; p++)
	{
		part[p] = model_read_part(partlist[|p])
		if (part[p] = null)
		{
			log("Could not read part list", name)
			return null
		}
	}
	
	ds_map_destroy(map)

	return id
}