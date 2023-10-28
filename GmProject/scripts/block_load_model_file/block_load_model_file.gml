/// block_load_model_file(filename, resource)
/// @arg filename
/// @arg [resource]

function block_load_model_file(fname, res = null)
{
	if (res = null && !is_undefined(load_assets_model_file_map[?filename_name(fname)])) // Previously loaded
		return load_assets_model_file_map[?filename_name(fname)]
	
	if (!file_exists_lib(fname))
	{
		log("Could not find model file", fname)
		return null
	}
	
	var typemap, map;
	typemap = ds_int_map_create()
	map = json_load(fname, typemap)
	if (!ds_map_valid(map))
	{
		log("Could not parse model file", fname)
		ds_map_destroy(typemap)
		return null
	}
	
	with (new_obj(obj_block_load_model_file))
	{
		name = filename_new_ext(filename_name(fname), "")
		
		// Parent
		parent = null
		if (res = null && is_string(map[?"parent"]))
			parent = block_load_model_file(load_assets_dir + mc_models_directory + string_replace(map[?"parent"], "minecraft:", "") + ".json")
		
		// Textures
		texture_map = null
		if (is_real(map[?"textures"]))
		{
			texture_map = ds_map_create()
			
			// Array of models, fill map with the string IDs
			if (ds_map_find_value(typemap[?map], "textures") = e_json_type.ARRAY && ds_list_valid(map[?"textures"]))
			{
				for (var i = 0; i < ds_list_size(map[?"textures"]); i++)
				{
					var texname = ds_list_find_value(map[?"textures"], i);
					texname = string_replace(texname, "minecraft:", "")
					
					texture_map[?string(i)] = block_load_model_file_texture(texname, res)
				}
			}
			
			// Regular map, copy keys and values
			else if (ds_map_valid(map[?"textures"]))
			{
				var key = ds_map_find_first(map[?"textures"]);
				while (!is_undefined(key))
				{
					var texname = ds_map_find_value(map[?"textures"], key);
					texname = string_replace(texname, "minecraft:", "")
					
					texture_map[?key] = block_load_model_file_texture(texname, res)
					key = ds_map_find_next(map[?"textures"], key)
				}
			}
		}
		
		// Element list
		element_amount = 0
		var elementslist = map[?"elements"];
		if (!is_undefined(elementslist))
		{
			var sortsize, sizelist;
			
			if (ds_list_size(elementslist) > 0)
			{
				sortsize = true
				sizelist = ds_list_create()
			}
			else
			{
				sortsize = false
				sizelist = null
			}
			
			for (var i = 0; i < ds_list_size(elementslist); i++)
			{
				with (new_obj(obj_block_load_element))
				{
					var elementmap = elementslist[|i];
					
					// From/To
					from = value_get_point3D(elementmap[?"from"])
					to = value_get_point3D(elementmap[?"to"])
					size = point3D_sub(to, from)
					volume = size[X] * size[Y] * size[Z]
					
					// Rotation
					var rotationmap = elementmap[?"rotation"];
					if (ds_map_valid(rotationmap))
					{
						var origin, angle, rot, scale;
						origin = value_get_point3D(rotationmap[?"origin"], point3D(8, 8, 8))
						angle = 0
						rot = vec3(0)
						scale = vec3(1)
						
						if (is_real(rotationmap[?"angle"]))
							angle = snap(clamp(rotationmap[?"angle"], -45, 45), 22.5)
						
						if (is_bool(rotationmap[?"rescale"]) && rotationmap[?"rescale"])
							scale = vec3(1 / dcos(abs(angle)))
						
						if (is_string(rotationmap[?"axis"]))
						{
							switch (rotationmap[?"axis"])
							{
								case "x": rot[X] = angle; scale[X] = 1; break
								case "z": rot[Y] = angle; scale[Y] = 1; break
								case "y": rot[Z] = angle; scale[Z] = 1; break
							}
						}
						
						matrix = matrix_create(point3D_mul(origin, -1), vec3(0), vec3(1))
						matrix = matrix_multiply(matrix, matrix_create(point3D(0, 0, 0), vec3(0), scale))
						matrix = matrix_multiply(matrix, matrix_create(origin, rot, vec3(1)))
						rotated = true
					}
					else
						rotated = false
					
					// Faces
					var facesmap = elementmap[?"faces"]
					for (var f = 0; f < e_dir.amount; f++)
					{
						var curmap = facesmap[?dir_get_string(f)];
						if (!is_undefined(curmap))
						{
							face_render[f] = true
							
							// UV
							face_has_uv[f] = false
							if (ds_list_valid(curmap[?"uv"]))
							{
								var uvlist = curmap[?"uv"];
								face_uv_from[f] = point2D(uvlist[|0], uvlist[|1])
								face_uv_to[f] = point2D(uvlist[|2], uvlist[|3])
								face_has_uv[f] = true
								
								// Limit to between 0 and 16
								var uvfrom, uvto;
								uvfrom = face_uv_from[f]
								uvto = face_uv_to[f]
								face_uv_from[f] = vec2(mod_fix(uvfrom[X], block_size + 0.1), mod_fix(uvfrom[Y], block_size + 0.1))
								face_uv_to[f] = vec2(mod_fix(uvto[X], block_size + 0.1), mod_fix(uvto[Y], block_size + 0.1))
							}
							
							// Texture
							face_texture[f] = curmap[?"texture"]
							
							// Rotation
							face_rotation[f] = 0
							if (is_real(curmap[?"rotation"]))
								face_rotation[f] = curmap[?"rotation"]
						}
						else
							face_render[f] = false
					}
					
					if (sortsize)
					{
						var pos;
						for (pos = 0; pos < ds_list_size(sizelist); pos++)
							if (sizelist[|pos].volume > volume)
								break
						
						ds_list_insert(sizelist, pos, id)
						
						other.element_amount++
					}
					else
					{
						other.element[other.element_amount++] = id
					}
				}
			}
			
			if (sortsize)
			{
				element = ds_list_create_array(sizelist)
				ds_list_destroy(sizelist)
			}
		}
		
		if (res = null)
			load_assets_model_file_map[?filename_name(fname)] = id
		
		ds_map_destroy(map)
		
		return id
	}
}
