/// block_load_model_file_texture(name, resource)
/// @arg name
/// @arg resource

var name, res, fn;
name = string_lower(argument0)
res = argument1

if (string_pos("assets/minecraft_", name) = 1)
	name = string_replace(name, "assets/minecraft_", "blocks/")

if (res = null)
	return name

fn = load_folder + "\\" + id.name + "\\" + name + ".png" // Look in exported folder
if (!file_exists_lib(fn)) // Look in the same folder
	fn = load_folder + "\\" + name + ".png"
if (!file_exists_lib(fn))
	fn = load_folder + "\\" + string_replace(name, "blocks/", "") + ".png" // Remove blocks/ and look in folder
if (!file_exists_lib(fn))
	fn = load_folder + "\\" + filename_name(name) + ".png" // Remove directory and look in folder
if (!file_exists_lib(fn))
	fn = load_folder + "\\..\\..\\textures\\" + name + ".png" // Look in textures folder
if (!file_exists_lib(fn))
	fn = load_folder + "\\..\\..\\textures\\item\\" + name + ".png" // Look in textures\item folder
if (!file_exists_lib(fn))
	fn = load_folder + "\\..\\..\\textures\\block\\" + name + ".png" // Look in textures\block folder
if (!file_exists_lib(fn))
	return name

if (res.model_texture_map = null)
	res.model_texture_map = ds_map_create()
else if (!is_undefined(res.model_texture_map[?name]))
	return name

res.model_texture_map[?name] = texture_create_square(fn)

return name