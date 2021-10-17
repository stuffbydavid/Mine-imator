/// res_save()
/// @desc Copies the file into the project directory.

function res_save()
{
	file_copy_lib(load_folder + "\\" + filename, save_folder + "\\" + filename)
	
	// Save model's own textures
	if (type = e_res_type.MODEL)
	{
		var name, key;
		name = filename_new_ext(filename, "")
		
		if (model_texture_map != null)
		{
			key = ds_map_find_first(model_texture_map)
			while (!is_undefined(key))
			{
				var fn = key;
				if (model_format = e_model_format.BLOCK) // Export to a folder with the model's name
					fn = name + "\\" + key + ".png"
			
				directory_create_lib(save_folder + "\\" + filename_dir(fn))
				texture_export(model_texture_map[?key], save_folder + "\\" + fn)
			
				key = ds_map_find_next(model_texture_map, key)
			}
		}
		
		if (model_material_texture_map != null)
		{
			key = ds_map_find_first(model_material_texture_map)
			while (!is_undefined(key))
			{
				var fn = key;
				if (model_format = e_model_format.BLOCK) // Export to a folder with the model's name
					fn = name + "\\" + key + ".png"
			
				directory_create_lib(save_folder + "\\" + filename_dir(fn))
				texture_export(model_material_texture_map[?key], save_folder + "\\" + fn)
			
				key = ds_map_find_next(model_material_texture_map, key)
			}
		}
		
		if (model_normal_texture_map != null)
		{
			key = ds_map_find_first(model_normal_texture_map)
			while (!is_undefined(key))
			{
				var fn = key;
				if (model_format = e_model_format.BLOCK) // Export to a folder with the model's name
					fn = name + "\\" + key + ".png"
			
				directory_create_lib(save_folder + "\\" + filename_dir(fn))
				texture_export(model_normal_texture_map[?key], save_folder + "\\" + fn)
			
				key = ds_map_find_next(model_normal_texture_map, key)
			}
		}
	}
}
