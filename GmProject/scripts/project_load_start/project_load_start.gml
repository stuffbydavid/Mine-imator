/// project_load_start(filename)
/// @arg filename
/// @desc Checks whether the format is correct

function project_load_start(fn)
{
	// Decode JSON
	var map = json_load(fn);
	if (!ds_map_valid(map))
	{
		log("Could not parse JSON file", fn)
		error("errorfilecorrupted")
		return null
	}
	
	// File format
	if (!is_real(map[?"format"]))
	{
		log("Missing parameter \"format\"")
		error("errorfilecorrupted")
		ds_map_destroy(map)
		return null
	}
	
	load_format = map[?"format"];
	
	// Check format too new
	if (load_format > project_format)
	{
		log("Too new project, format", load_format)
		error("erroropenprojectnewer")
		ds_map_destroy(map)
		return null
	}
	
	// Check format too old
	else if (load_format < e_project.FORMAT_110_PRE_1)
	{
		log("Invalid format", load_format)
		error("errorfilecorrupted")
		ds_map_destroy(map)
		return null
	}
	
	log("load_format", load_format)
	
	return map
}
