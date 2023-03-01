/// model_file_load_texture_material(name, resource)
/// @arg name
/// @arg resource

function model_file_load_texture_material(name, res)
{
	var ext = filename_ext(name);
	if (ext != ".png" && ext != ".jpg" && ext != ".jpeg")
		return 0
	
	if (res.model_texture_material_map = null)
		res.model_texture_material_map = ds_map_create()
	else if (!is_undefined(res.model_texture_material_map[?name]))
		return 0
	
	res.model_texture_material_map[?name] = texture_create_square(load_folder + "/" + name)
}