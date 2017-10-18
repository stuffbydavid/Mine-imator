/// language_load(filename, map)
/// @arg filename
/// @arg map

var fn, map;
fn = argument0
map = argument1

log("Loading language file", fn)

ds_map_clear(map)
	
if (filename_ext(fn) = ".milanguage")
{
	// Convert unicode (external)
	//var convfn = file_directory + "conv.tmp";
	//show_message(string(file_json_convert_unicode(fn, convfn)))
	
	// Load JSON
	var jsonmap = json_load(fn);
	language_load_map("", jsonmap, map)

	if (ds_map_valid(jsonmap))
		ds_map_destroy(jsonmap)
}
else
	language_load_legacy(fn, map)

// Check keys
var missingkeyslist, key;
missingkeyslist = ds_list_create()
key = ds_map_find_first(language_english_map);
while (!is_undefined(key))
{
	if (is_undefined(map[?key]))
		ds_list_add(missingkeyslist, key)
	key = ds_map_find_next(language_english_map, key)	
}

if (ds_list_size(missingkeyslist) > 0)
{
	ds_list_sort(missingkeyslist, true)
	
	var str = "The following keys are missing from the translation and will display an erroneous text:\n"
	for (var i = 0; i < ds_list_size(missingkeyslist); i++)
		str += missingkeyslist[|i] + ": " + string_replace_all(language_english_map[?missingkeyslist[|i]], "\n", "\\n") + "\n"
		
	log(str)
}
