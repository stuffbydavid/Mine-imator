/// project_load_start(filename)
/// @arg filename
/// @desc Checks whether the format is correct

var fn = argument0;
	
// Decode JSON
var json, map;
json = file_text_contents(fn)
map = json_decode(json)
if (map < 0)
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
else if (load_format < e_project.FORMAT_110)
{
	log("Invalid format", load_format)
	error("errorfilecorrupted")
	ds_map_destroy(map)
	return null
}

log("load_format", load_format)

return map