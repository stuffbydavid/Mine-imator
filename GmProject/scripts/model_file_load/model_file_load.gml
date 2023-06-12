/// model_file_load(filename, resource)
/// @arg filename
/// @arg [resource]
/// @desc Loads the parts and shapes from the selected filename.

function model_file_load(fname, res = null)
{
	if (!file_exists_lib(fname))
	{
		log("Could not find model file", fname)
		return null
	}
	
	var map = json_load(fname);
	if (!ds_map_valid(map))
	{
		log("Could not parse model file", fname)
		return null
	}
	
	// Check required fields
	if (!is_string(map[?"name"]))
	{
		log("Missing parameter \"name\"")
		return null
	}
	
	if (!is_string(map[?"texture"]))
	{
		log("Missing parameter \"texture\"")
		return null
	}
	
	if (!ds_list_valid(map[?"texture_size"]))
	{
		log("Missing array \"texture_size\"")
		return null
	}
	
	if (!ds_list_valid(map[?"parts"]))
	{
		log("Missing array \"parts\"")
		return null
	}
	
	with (new_obj(obj_model_file))
	{
		// Name
		name = map[?"name"]
		
		if (res = null && dev_mode_debug_names && !text_exists("model" + name))
			log("model/" + name + dev_mode_name_translation_message)
		
		// Description (optional)
		description = value_get_string(map[?"description"], "")
		
		// Texture
		texture_name = map[?"texture"]
		texture_inherit = id
		texture_material_inherit = id
		texture_normal_inherit = id
		if (res != null)
			model_file_load_texture(texture_name, res)
		
		// Only read material textures if user-made .mimodel
		if (res != null)
		{
			texture_material_name = value_get_string(map[?"texture_material"], "")
			if (texture_material_name != "")
				model_file_load_texture_material(texture_material_name, res)
			
			texture_normal_name = value_get_string(map[?"texture_normal"], "")
			if (texture_normal_name != "")
				model_file_load_tex_normal(texture_normal_name, res)
		}
		else
		{
			texture_material_name = texture_name
			texture_normal_name = texture_name
		}
		
		// Texture size
		texture_size = value_get_point2D(map[?"texture_size"])
		var size = max(texture_size[X], texture_size[Y]);
		texture_size = vec2(size, size) // Make square
		
		// Color
		part_mixing_shapes = false
		color_inherit = false
		color_blend = c_white
		color_alpha = 1
		color_emissive = 0
		color_mix = c_black
		color_mix_percent = 0
		
		// Player skin
		player_skin = value_get_real(map[?"player_skin"], false)
		
		// Scale (optional)
		scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
		
		// Bounds in default position
		bounds_parts_start = point3D(no_limit, no_limit, no_limit)
		bounds_parts_end = point3D(-no_limit, -no_limit, -no_limit)
		
		// Whether this file contains 3D planes that need to be regenerated on texture switches
		has_3d_plane = false
		
		// Read all the parts of the root
		var partlist = map[?"parts"]
		render_part_list = ds_list_create()
		file_part_list = ds_list_create()
		part_list = ds_list_create()
		for (var p = 0; p < ds_list_size(partlist); p++)
		{
			var part = model_file_load_part(partlist[|p], id, res, id)
			if (part = null)
				return null
			if (part > 0)
				ds_list_add(part_list, part)
		}
		
		ds_map_destroy(map)
		
		return id
	}
}
