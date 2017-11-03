/// block_model_file_load_texture(name, resource)
/// @arg name
/// @arg resource

var name, res, fn;
name = argument0
res = argument1

fn = string_replace(name, "blocks/", "") + ".png"
if (!file_exists_lib(load_folder + "\\" + fn))
	return 0

if (res.model_texture_map = null)
	res.model_texture_map = ds_map_create()
else if (!is_undefined(res.model_texture_map[?name]))
	return 0

res.model_texture_map[?name] = texture_create_square(load_folder + "\\" + fn)