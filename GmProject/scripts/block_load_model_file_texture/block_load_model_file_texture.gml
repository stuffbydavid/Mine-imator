/// @arg name
/// @arg resource

function block_load_model_file_texture(name, res)
{
	name = string_lower(name)
	
	if (string_pos("assets/minecraft_", name) = 1)
		name = string_replace(name, "assets/minecraft_", "block/")
	
	if (res = null)
		return name
	
	// Legacy name
	if (string_pos("blocks/", name) = 1)
	{
		name = string_replace(name, "blocks/", "block/")
		
		var newname = ds_map_find_key(legacy_block_texture_name_map, name);
		name = (is_undefined(newname) ? name : newname)
	}
	
	// Relative lookup paths
	var paths, fn;
	paths = [
		"/" + self.name + "/" + name + ".png",
		"/" + name + ".png",
		"/" + string_replace(name, "blocks/", "") + ".png",
		"/" + string_replace(name, "block/", "") + ".png",
		"/" + filename_name(name) + ".png",
		"/../../textures/" + name + ".png",
		"/../../textures/item/" + name + ".png",
		"/../../textures/block/" + name + ".png"
	]
	fn = ""

	for (var i = 0; i < array_length(paths); i++)
	{
		var path = load_folder + paths[i];
		if (file_exists_lib(path))
		{
			fn = path
			break
		}
	}

	if (fn = "")
		return name
	
	if (res.model_texture_map = null)
		res.model_texture_map = ds_map_create()
	else if (!is_undefined(res.model_texture_map[?name]))
		return name
	
	res.model_texture_map[?name] = texture_create_square(fn)
	
	return name
}
