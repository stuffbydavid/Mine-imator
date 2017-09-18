/// model_file_load(filename)
/// @arg filename
/// @desc Loads the parts and shapes from the selected filename.

var fname  = argument0;
	
if (!file_exists_lib(fname))
{
	log("Could not find model file", fname)
	return null
}

var map = json_load(fname);
if (!ds_map_valid(map))
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

if (!ds_list_valid(map[?"texture_size"]))
{
	log("Missing array \"texture_size\"")
	return null
}

if (!ds_list_valid(map[?"parts"]))
{
	log("Missing array \"parts\"")
	return null
}

with (new(obj_model_file))
{
	// Name
	if (is_string(map[?"name"]))
		name = map[?"name"]
	else
	{
		log("Missing parameter \"name\"")
		return null
	}
	
	// Description (optional)
	if (is_string(map[?"description"]))
		description = map[?"description"]
	else
		description = ""
		
	// Texture
	texture_name = map[?"texture"]
	texture_inherit = id
	
	// Texture size
	texture_size = value_get_point2D(map[?"texture_size"])

	// Player skin
	if (is_real(map[?"player_skin"]))
		player_skin = map[?"player_skin"]
	else
		player_skin = false
	
	// Bounds in default position
	bounds_parts_start = point3D(no_limit, no_limit, no_limit)
	bounds_parts_end = point3D(-no_limit, -no_limit, -no_limit)
	
	// Read all the parts of the root
	var partlist = map[?"parts"]
	file_part_list = ds_list_create()
	part_list = ds_list_create()
	for (var p = 0; p < ds_list_size(partlist); p++)
	{
		var part = model_file_load_part(partlist[|p], id)
		if (part = null)
		{
			log("Could not read part", name)
			return null
		}
		ds_list_add(part_list, part)
	}
	
	ds_map_destroy(map)

	return id
}