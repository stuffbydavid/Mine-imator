/// model_file_load_texture(filename, resource)
/// @arg filename
/// @arg resource

var fn, fnext, res;
fn = argument0
res = argument1

fnext = filename_ext(fn)
if (fnext != ".png" && fnext != ".jpg" && fnext != ".jpeg")
	return 0
	
if (res.model_texture_map = null)
	res.model_texture_map = ds_map_create()
else if (!is_undefined(res.model_texture_map[?fn]))
	return 0
	
res.model_texture_map[?fn] = texture_create_square(load_folder + "\\" + fn)