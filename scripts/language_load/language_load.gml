/// language_load(filename, map)
/// @arg filename
/// @arg map

var fn, map, json, jsonmap;
fn = argument0
map = argument1

ds_map_clear(map)

log("Load language file", fn)
json = file_text_contents(fn)

if (json = "")
	return 0

jsonmap = json_decode(json)
language_load_map("", jsonmap, map)

if (ds_exists(jsonmap, ds_type_map))
	ds_map_destroy(jsonmap)