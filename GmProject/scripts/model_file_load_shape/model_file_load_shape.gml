/// model_file_load_shape(map, resource)
/// @arg map
/// @arg resource
/// @desc Adds a shape from the given map (JSON object)

function model_file_load_shape(map, res)
{
	// Check invisible
	if (!is_undefined(map[?"visible"]) && !map[?"visible"])
		return 0
	
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
	
	with (new_obj(obj_model_shape))
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
			texture_material_inherit = id
			texture_normal_inherit = id
			
			// Texture size
			if (!ds_list_valid(map[?"texture_size"]))
			{
				log("Missing array \"texture_size\"")
				return null
			}
			
			if (res != null)
			{
				model_file_load_texture(texture_name, res)
				
				texture_material_name = value_get_string(map[?"texture_material"], "")
				texture_normal_name = value_get_string(map[?"texture_normal"], "")
				
				if (texture_material_name != "")
					model_file_load_texture_material(texture_material_name, res)
				else
					texture_material_inherit = other.texture_material_inherit
				
				if (texture_normal_name != "")
					model_file_load_tex_normal(texture_normal_name, res)
				else
					texture_normal_inherit = other.texture_normal_inherit
			}
			else
			{
				texture_material_name = texture_name
				texture_normal_name = texture_name
			}
			
			texture_size = value_get_point2D(map[?"texture_size"])
			var size = max(texture_size[X], texture_size[Y]);
			texture_size = vec2(size, size) // Make square
		}
		else
		{
			// Inherit
			texture_name = ""
			texture_material_name = ""
			texture_normal_name = ""
			texture_inherit = other.texture_inherit
			texture_material_inherit = other.texture_material_inherit
			texture_normal_inherit = other.texture_normal_inherit
			texture_size = texture_inherit.texture_size
		}
		
		// Color (optional)
		color_inherit = value_get_real(map[?"color_inherit"], true)
		color_blend = value_get_color(map[?"color_blend"], c_white)
		color_alpha = value_get_real(map[?"color_alpha"], 1)
		
		// Legacy 'brightness' support
		if (is_real("color_emissive"))
			color_emissive = value_get_real(map[?"color_emissive"], 0)
		else
			color_emissive = value_get_real(map[?"color_brightness"], 0)
		
		color_mix = value_get_color(map[?"color_mix"], c_black)
		color_mix_percent = value_get_real(map[?"color_mix_percent"], 0)
		
		if (color_inherit)
		{
			color_blend = color_multiply(color_blend, other.color_blend)
			color_alpha *= other.color_alpha
			color_emissive = clamp(color_emissive + other.color_emissive, 0, 1)
			color_mix = color_add(color_mix, other.color_mix)
			color_mix_percent = clamp(color_mix_percent + other.color_mix_percent, 0, 1)
		}
		
		if (color_mix_percent > 0)
			other.part_mixing_shapes = true
		
		// Minecraft color (Only used in states)
		minecraft_color = c_white
		
		// Mirror (optional)
		texture_mirror = value_get_real(map[?"texture_mirror"], false)
		
		// Invert (optional)
		invert = value_get_real(map[?"invert"], false)
		
		// Hide front/back plane faces
		hide_front = value_get_real(map[?"hide_front"], false)
		hide_back = value_get_real(map[?"hide_back"], false)
		
		// Hide backface (old name, for legacy support)
		if (is_bool(map[?"hide_backface"]))
			hide_back = map[?"hide_backface"]
		
		// Face camera (optional, overrides rotation when rendering)
		face_camera = value_get_real(map[?"face_camera"], false)
		
		// Item bounce (optional)
		item_bounce = value_get_real(map[?"item_bounce"], false)
		
		// Move required (optional, amount of position moved from part's timeline to be visible)
		move_required_array = value_get_point3D(map[?"move_required"], vec3(-1, -1, -1))
		if (!array_equals(move_required_array, vec3(-1)))
			move_required = true
		else
			move_required = false
		
		// From/To
		from_noscale = value_get_point3D(map[?"from"])
		to_noscale = value_get_point3D(map[?"to"])
		if (type = "plane")
			to_noscale[Y] = from_noscale[Y]
		
		// Inflate (optional)
		inflate = vec3(value_get_real(map[?"inflate"], 0))
		if (type = "plane")
			to_noscale[Y] = from_noscale[Y]
		
		// 3D plane (optional)
		is3d = false
		if (type = "plane")
		{
			is3d = value_get_real(map[?"3d"], false)
			
			// 3D planes expand on Y axis, 2D planes don't
			if (is3d)
			{
				other.has_3d_plane = true
				to_noscale[Y] += 1
			}
			else
				inflate[Y] = 0
		}
		
		// Position (optional)
		position_noscale = value_get_point3D(map[?"position"], point3D(0, 0, 0))
		position = point3D_mul(position_noscale, other.scale)
		
		// Rotation (optional)
		rotation = value_get_point3D(map[?"rotation"], vec3(0, 0, 0))
		
		// Scale (optional)
		scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
		scale = vec3_mul(scale, other.scale)
		from = point3D_mul(point3D_sub(from_noscale, inflate), scale)
		to = point3D_mul(point3D_add(to_noscale, inflate), scale)
		
		// Locked shape
		locked = value_get_real(map[?"locked"], false)
		
		// Bending
		bend_shape = value_get_real(map[?"bend"], true)
		bend_part = other.bend_part
		bend_axis = other.bend_axis
		bend_direction_min = other.bend_direction_min
		bend_direction_max = other.bend_direction_max
		bend_default_angle = other.bend_default_angle
		bend_offset = other.bend_offset
		bend_size = other.bend_size
		bend_invert = other.bend_invert
		
		// Create matrix
		matrix = matrix_create(position, vec3(0), vec3(1))
		
		// UV
		uv = value_get_point2D(map[?"uv"])
		
		// Wind
		wind_wave = e_vertex_wave.NONE
		wind_wave_zmin = null
		wind_wave_zmax = null
		
		var windmap = map[?"wind"];
		if (ds_map_valid(windmap))
		{
			if (is_string(windmap[?"axis"]))
			{
				if (windmap[?"axis"] = "y")
					wind_wave = e_vertex_wave.Z_ONLY
				else
					wind_wave = e_vertex_wave.ALL
			}
			
			if (is_real(windmap[?"ymin"]))
				wind_wave_zmin = windmap[?"ymin"]
			
			if (is_real(windmap[?"ymax"]))
				wind_wave_zmax = windmap[?"ymax"]
		}
		
		// Generate default mesh
		if (type = "block")
		{
			vbuffer_default = model_shape_generate_block(vec3(0))
			if (other.name = "head" && player_head_vbuffer = null) // Set player head model for world importer
				player_head_vbuffer = vbuffer_default
		}
		else if (type = "plane")
			vbuffer_default = model_shape_generate_plane(vec3(0))
		else
		{
			vbuffer_default = null
			log("Invalid shape type", type)
			return null
		}
		
		// Update bounds
		var boundsmat = matrix_create(position, rotation, vec3(1))
		var startpos = point3D_mul_matrix(from, boundsmat);
		var endpos = point3D_mul_matrix(to, boundsmat);
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
		
		return id
	}
}
