/// language_load(filename, map)
/// @arg filename
/// @arg map

var fn, map, jsonmap;
fn = argument0
map = argument1

ds_map_clear(map)

log("Load language file", fn)
var jsonmap = json_load(fn);
language_load_map("", jsonmap, map)

if (ds_map_valid(jsonmap))
	ds_map_destroy(jsonmap)