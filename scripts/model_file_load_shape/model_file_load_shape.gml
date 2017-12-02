/// model_file_load_shape(map, resource)
/// @arg map
/// @arg resource
/// @desc Adds a shape from the given map (JSON object)

var map, res;
map = argument0
res = argument1

// Check required fields
if (!is_string(map[?"type"]))
{
	log("Missing parameter \"type\"")
	return null
}

if (!ds_list_valid(map[?"from"]))
{
	log("Missing array \"from\"")
	return null
}

if (!ds_list_valid(map[?"to"]))
{
	log("Missing array \"to\"")
	return null
}

if (!ds_list_valid(map[?"uv"]))
{
	log("Missing array \"uv\"")
	return null
}

with (new(obj_model_shape))
{
	// Type
	type = map[?"type"]

	// Description (optional)
	description = value_get_string(map[?"description"], "")
		
	// Texture (optional)
	if (is_string(map[?"texture"]))
	{
		texture_name = map[?"texture"]
		texture_inherit = id
		
		// Texture size
		if (!ds_list_valid(map[?"texture_size"]))
		{
			log("Missing array \"texture_size\"")
			return null
		}
		
		if (res != null)
			model_file_load_texture(texture_name, res)
			
		texture_size = value_get_point2D(map[?"texture_size"])
		var size = max(texture_size[X], texture_size[Y]);
		texture_size = vec2(size, size) // Make square
	}
	else
	{
		// Inherit
		texture_name = ""
		texture_inherit = other.texture_inherit
		texture_size = texture_inherit.texture_size
	}
	
	// Color (optional)
	color_inherit = value_get_real(map[?"color_inherit"], true)
	color_blend = value_get_color(map[?"color_blend"], c_white)
	color_alpha = value_get_real(map[?"color_alpha"], 1)
	color_brightness = value_get_real(map[?"color_brightness"], 0)
	
	if (color_inherit)
	{
		color_blend = color_multiply(color_blend, other.color_blend)
		color_alpha *= other.color_alpha
		color_brightness += other.color_brightness
	}
	
	// Mirror (optional)
	texture_mirror = value_get_real(map[?"texture_mirror"], false)
	
	// Invert (optional)
	invert = value_get_real(map[?"invert"], false)
	
	// From/To
	from_noscale = value_get_point3D(map[?"from"])
	to_noscale = value_get_point3D(map[?"to"])
	
	// Position (optional)
	position_noscale = value_get_point3D(map[?"position"], point3D(0, 0, 0))
	position = point3D_mul(position_noscale, other.scale)
		
	// Rotation (optional)
	rotation = value_get_point3D(map[?"rotation"], vec3(0, 0, 0))
		
	// Scale (optional)
	scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
	scale = vec3_mul(scale, other.scale)
	from = point3D_mul(from_noscale, scale)
	to = point3D_mul(to_noscale, scale)
	
	// 3D plane (optional)
	is3d = false
	if (type = "plane")
		is3d = value_get_real(map[?"3d"], false)
	
	// Bending
	bend_part = other.bend_part
	bend_axis = other.bend_axis
	bend_direction = other.bend_direction
	bend_offset = other.bend_offset
	bend_size = other.bend_size
	bend_invert = other.bend_invert
	
	// Create matrices
	matrix = matrix_create(position, rotation, vec3(1))
	matrix_bend_half = matrix_create(point3D(0, 0, 0), rotation, vec3(1))
	
	// UV
	uv = value_get_point2D(map[?"uv"])
	
	// Wind
	var windmap = map[?"wind"];
	if (ds_map_valid(windmap))
	{
		if (is_string(windmap[?"axis"]))
		{
			if (windmap[?"axis"] = "y")
				vertex_wave = e_vertex_wave.Z_ONLY
			else
				vertex_wave = e_vertex_wave.ALL
		}
		
		if (is_real(windmap[?"ymin"]))
			vertex_wave_zmin = windmap[?"ymin"]
			
		if (is_real(windmap[?"ymax"]))
			vertex_wave_zmax = windmap[?"ymax"]
	}
	
	vertex_brightness = color_brightness
	
	// Generate
	if (type = "block")
		vbuffer = model_shape_generate_block(0)
	else if (type = "plane")
	{
		to[Y] = from[Y]
		
		if (is3d)
		{
			to[Y] = from[Y] + scale[Z]
			other.has_3d_plane = true
		}
		
		vbuffer = model_shape_generate_plane(null, 0)
	}
	else
	{
		log("Invalid shape type", type)
		return null
	}
	
	// Update bounds
	var startpos = point3D_mul_matrix(from, matrix);
	var endpos   = point3D_mul_matrix(to, matrix);
	bounds_start[X] = min(startpos[X], endpos[X])
	bounds_start[Y] = min(startpos[Y], endpos[Y])
	bounds_start[Z] = min(startpos[Z], endpos[Z])
	bounds_end[X]	= max(startpos[X], endpos[X])
	bounds_end[Y]	= max(startpos[Y], endpos[Y])
	bounds_end[Z]	= max(startpos[Z], endpos[Z])
	other.bounds_start[X] = min(other.bounds_start[X], bounds_start[X])
	other.bounds_start[Y] = min(other.bounds_start[Y], bounds_start[Y])
	other.bounds_start[Z] = min(other.bounds_start[Z], bounds_start[Z])
	other.bounds_end[X] = max(other.bounds_end[X], bounds_end[X])
	other.bounds_end[Y] = max(other.bounds_end[Y], bounds_end[Y])
	other.bounds_end[Z] = max(other.bounds_end[Z], bounds_end[Z])
	
	// Reset wind and brightness
	vertex_wave = e_vertex_wave.NONE
	vertex_wave_zmin = null
	vertex_wave_zmax = null
	vertex_brightness = 0
	
	return id
}