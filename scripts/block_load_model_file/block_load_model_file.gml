/// block_load_model_file(filename)
/// @arg filename

var fname, fpath;
fname = argument0
fpath = unzip_directory + "\\assets\\minecraft\\models\\" + fname

if (!is_undefined(mc_block_model_file_map[?fname])) // Previously loaded
	return mc_block_model_file_map[?fname]

if (!file_exists_lib(fpath))
{
	log("Could not find model file", fname)
	return null
}

var map = json_load(fpath);
if (!ds_map_valid(map))
{
	log("Could not parse model file", fname)
	return null
}

with (new(obj_block_load_model_file))
{
	// Parent
	parent = null
	if (is_string(map[?"parent"]))
		parent = block_load_model_file(map[?"parent"] + ".json")
		
	// Textures
	texture_map = null
	if (ds_map_valid(map[?"textures"]))
	{
		texture_map = ds_map_create()
		ds_map_copy(texture_map, map[?"textures"])
	}
	
	// Element list
	element_amount = 0
	var elementslist = map[?"elements"];
	if (!is_undefined(elementslist))
	{
		for (var i = 0; i < ds_list_size(elementslist); i++)
		{
			with (new(obj_block_load_element))
			{
				var elementmap = elementslist[|i];
				
				// From/To
				from = value_get_point3D(elementmap[?"from"])
				to = value_get_point3D(elementmap[?"to"])
				
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
						
					if (is_real(rotationmap[?"rescale"]) && rotationmap[?"rescale"])
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
				{
					matrix = MAT_IDENTITY
					rotated = false
				}
				
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
						}
						
						// Texture
						face_texture[f] = curmap[?"texture"]
						
						// Cull face
						face_cullface[f] = null
						if (is_string(curmap[?"cullface"]))
							face_cullface[f] = string_to_dir(curmap[?"cullface"])
							
						// Rotation
						face_rotation[f] = 0
						if (is_real(curmap[?"rotation"]))
							face_rotation[f] = curmap[?"rotation"]
					}
					else
						face_render[f] = false
				}
				
				other.element[other.element_amount++] = id
			}
		}
	}
	
	mc_block_model_file_map[?fname] = id
	ds_map_destroy(map)
	
	return id
}