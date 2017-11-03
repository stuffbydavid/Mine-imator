/// res_save()
/// @desc Copies the file into the project directory.

file_copy_lib(load_folder + "\\" + filename, save_folder + "\\" + filename)

// Save model's own textures
if (type = e_res_type.MODEL && model_texture_map != null)
{
	var key = ds_map_find_first(model_texture_map);
	while (!is_undefined(key))
	{
		var fn = key;
		if (model_format = e_model_format.BLOCK)
			fn = string_replace(fn, "blocks/", "") + ".png"
			
		if (filename_dir(fn) != "") // Create folder structure to image
			directory_create_lib(save_folder + "\\" + filename_dir(fn))
		file_copy_lib(load_folder + "\\" + fn, save_folder + "\\" + fn)

		key = ds_map_find_next(model_texture_map, key)
	}
}