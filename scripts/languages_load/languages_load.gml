/// languages_load()

function languages_load()
{
	var fn = languages_file;
	
	if (!file_exists_lib(fn))
		return 0
	
	log("Loading languages", fn)
	
	// Decode
	var map = json_load(fn);
	if (!ds_map_valid(map))
		return 0
	
	load_format = map[?"format"]
	log("load_format", load_format)
	
	var list, obj;
	list = map[?"languages"]
	
	for (var i = 0; i < ds_list_size(list); i++)
	{
		map = list[|i]
		
		var name, locale, fn;
		name = value_get_string(map[?"name"], "")
		locale = value_get_string(map[?"locale"], "")
		fn = value_get_string(map[?"filename"], "")
		
		language_remove(fn)
		
		var obj = new_obj(obj_language);
		obj.name = name
		obj.locale = locale
		obj.filename = fn
	}
	
	ds_list_destroy(list)
}
