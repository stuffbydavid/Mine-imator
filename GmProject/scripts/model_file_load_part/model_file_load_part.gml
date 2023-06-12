/// model_file_load_part(map, root, resource, model)
/// @arg map
/// @arg root
/// @arg resource
/// @arg model
/// @desc Adds a part from the given map (JSON object) and returns its instance.

function model_file_load_part(map, root, res, model)
{
	// Check invisible
	if (!is_undefined(map[?"visible"]) && !map[?"visible"])
		return 0
	
	// Check required fields
	if (!is_string(map[?"name"]))
	{
		log("Missing parameter \"name\"")
		return null
	}
	
	if (!ds_list_valid(map[?"position"]))
	{
		log("Missing array \"position\"")
		return null
	}
	
	// Check if unique part name
	for (var i = 0; i < ds_list_size(root.file_part_list); i++)
	{
		if (root.file_part_list[|i].name = map[?"name"])
		{
			log("Duplicate part name found", map[?"name"])
			return null
		}
	}
	
	with (new_obj(obj_model_part))
	{
		// Name
		name = map[?"name"]
		
		if (res = null && dev_mode_debug_names && !text_exists("modelpart" + name))
			log("model/part/" + name + dev_mode_name_translation_message)
		
		// Depth
		depth = value_get_real(map[?"depth"], 0)
		
		var pos;
		for (pos = 0; pos < ds_list_size(model.render_part_list); pos++)
			if (model.render_part_list[|pos].depth > depth)
				break
		
		ds_list_insert(model.render_part_list, pos, id)
		
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
		part_mixing_shapes = false
		
		if (color_inherit)
		{
			color_blend = color_multiply(color_blend, other.color_blend)
			color_alpha *= other.color_alpha
			color_emissive = clamp(color_emissive + other.color_emissive, 0, 1)
			color_mix = color_add(color_mix, other.color_mix)
			color_mix_percent = clamp(color_mix_percent + other.color_mix_percent, 0, 1)
		}
		
		if (color_mix_percent > 0)
			part_mixing_shapes = true
		
		// Position
		position_noscale = value_get_point3D(map[?"position"])
		position = point3D_mul(position_noscale, other.scale)
		
		// Rotation (optional)
		rotation = value_get_point3D(map[?"rotation"], vec3(0, 0, 0))
		
		// Scale (optional)
		scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
		scale = vec3_mul(scale, other.scale)
		
		// Keyframe tab states
		show_position = value_get_real(map[?"show_position"], false)
		
		// Locked timeline
		if (other.object_index = obj_model_part && other.locked)
			locked = true
		else
			locked = value_get_real(map[?"locked"], false)
		
		// Locked to parent bend half?
		lock_bend = true
		if (other.object_index = obj_model_part && other.bend_part != null)
		{
			if (is_bool(map[?"lock_bend"]) || is_real(map[?"lock_bend"]))
				lock_bend = map[?"lock_bend"]
			
			if (lock_bend)
			{
				switch (other.bend_part)
				{
					case e_part.LEFT:
					case e_part.RIGHT:
							position[X] -= other.bend_offset
						break
					
					case e_part.BACK:
					case e_part.FRONT:
							position[Y] -= other.bend_offset
						break
					
					case e_part.LOWER:
					case e_part.UPPER:
							position[Z] -= other.bend_offset
						break
				}
			}
		}
		
		// Show backfaces
		backfaces = value_get_real(map[?"backfaces"], false)
		
		// Bend (optional)
		if (!is_undefined(map[?"bend"]))
		{
			var bendmap = map[?"bend"]
			
			// Inherit angles
			bend_inherit = value_get_real(bendmap[?"inherit_bend"], false)
			
			// Offset
			if (!is_real(bendmap[?"offset"]))
			{
				log("Missing parameter \"offset\"")
				return null
			}
			bend_offset = bendmap[?"offset"]
			
			// End offset
			bend_end_offset = value_get_real(bendmap[?"end_offset"], 0)
			
			// Size
			bend_size = value_get_real(bendmap[?"size"], null)
			
			// Part
			if (!is_string(bendmap[?"part"])) 
			{
				log("Missing parameter \"part\"")
				return null
			}
			
			switch (bendmap[?"part"])
			{
				case "right":	bend_part = e_part.RIGHT;	bend_offset *= scale[X];	if (bend_size != null) bend_size *= scale[X];	bend_pos_offset = point3D(bend_offset, 0, 0); break
				case "left":	bend_part = e_part.LEFT;	bend_offset *= scale[X];	if (bend_size != null) bend_size *= scale[X];	bend_pos_offset = point3D(bend_offset, 0, 0); break
				case "front":	bend_part = e_part.FRONT;	bend_offset *= scale[Y];	if (bend_size != null) bend_size *= scale[Y];	bend_pos_offset = point3D(0, bend_offset, 0); break
				case "back":	bend_part = e_part.BACK;	bend_offset *= scale[Y];	if (bend_size != null) bend_size *= scale[Y];	bend_pos_offset = point3D(0, bend_offset, 0); break
				case "upper":	bend_part = e_part.UPPER;	bend_offset *= scale[Z];	if (bend_size != null) bend_size *= scale[Z];	bend_pos_offset = point3D(0, 0, bend_offset); break
				case "lower":	bend_part = e_part.LOWER;	bend_offset *= scale[Z];	if (bend_size != null) bend_size *= scale[Z];	bend_pos_offset = point3D(0, 0, bend_offset); break
				default:
					log("Invalid parameter \"part\"")
					return null
			}
			
			// Axis
			bend_axis = array(false, false, false);
			var axis = array();
			if (is_string(bendmap[?"axis"])) // Single
			{
				switch (bendmap[?"axis"])
				{
					case "x":	bend_axis[X] = true; array_add(axis, X);	break
					case "z":	bend_axis[Y] = true; array_add(axis, Y);	break
					case "y":	bend_axis[Z] = true; array_add(axis, Z);	break
					default:
						log("Invalid parameter \"axis\"")
						return null
				}
			}
			else if (ds_list_valid(bendmap[?"axis"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"axis"]); i++)
				{
					switch (ds_list_find_value(bendmap[?"axis"], i))
					{
						case "x":	bend_axis[X] = true; array_add(axis, X);	break
						case "z":	bend_axis[Y] = true; array_add(axis, Y);	break
						case "y":	bend_axis[Z] = true; array_add(axis, Z);	break
						default:
							log("Invalid parameter \"axis\"")
							return null
					}
				}
			}
			else
			{
				log("Missing parameter \"axis\"")
				return null
			}
			
			// Bend range(Minimum)
			bend_direction_min = vec3(-180)
			if (is_real(bendmap[?"direction_min"]) && array_length(axis) = 1) // Single
			{
				bend_direction_min[axis[0]] = bendmap[?"direction_min"]
			}
			else if (ds_list_valid(bendmap[?"direction_min"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"direction_min"]); i++)
					bend_direction_min[axis[i]] = ds_list_find_value(bendmap[?"direction_min"], i)
			}
			
			// Bend range(Maximum)
			bend_direction_max = vec3(180)
			if (is_real(bendmap[?"direction_max"]) && array_length(axis) = 1) // Single
			{
				bend_direction_max[axis[0]] = bendmap[?"direction_max"]
			}
			else if (ds_list_valid(bendmap[?"direction_max"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"direction_max"]); i++)
					bend_direction_max[axis[i]] = ds_list_find_value(bendmap[?"direction_max"], i)
			}
			
			// Direction(Legacy)
			bend_direction = array(0, 0, 0)
			bend_direction_legacy = false
			if (is_string(bendmap[?"direction"])) // Single
			{
				switch (bendmap[?"direction"])
				{
					case "forward":		bend_direction[axis[0]] = e_bend.FORWARD;	break
					case "backward":	bend_direction[axis[0]] = e_bend.BACKWARD;	break
					case "both":		bend_direction[axis[0]] = e_bend.BOTH;		break
					default:
						log("Invalid parameter \"direction\"")
						return null
				}
				bend_direction_legacy = true
			}
			else if (ds_list_valid(bendmap[?"direction"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"direction"]); i++)
				{
					switch (ds_list_find_value(bendmap[?"direction"], i))
					{
						case "forward":		bend_direction[axis[i]] = e_bend.FORWARD;	break
						case "backward":	bend_direction[axis[i]] = e_bend.BACKWARD;	break
						case "both":		bend_direction[axis[i]] = e_bend.BOTH;		break
						default:
							log("Invalid parameter \"direction\"")
							return null
					}
					bend_direction_legacy = true
				}
			}
			
			// Invert
			if ((is_real(bendmap[?"invert"]) || is_bool(bendmap[?"invert"])) && array_length(axis) = 1) // Single
			{
				bend_invert = vec3(bendmap[?"invert"])
			}
			else if (ds_list_valid(bendmap[?"invert"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"invert"]); i++)
					bend_invert[axis[i]] = ds_list_find_value(bendmap[?"invert"], i)
			}
			else
				bend_invert = vec3(false)
			
			// Convert legacy direction to limits
			if (bend_direction_legacy)
			{
				for (var i = X; i <= Z; i++)
				{
					if (bend_direction[i] = e_bend.BOTH)
					{
						bend_direction_min[i] = -180
						bend_direction_max[i] = 180
					}
					else if (bend_direction[i] = e_bend.FORWARD)
					{
						bend_direction_min[i] = 0
						bend_direction_max[i] = 180
						bend_invert[i] = !bend_invert[i] // 'forward' previously inverted angle
					}
					else
					{
						bend_direction_min[i] = 0
						bend_direction_max[i] = 180
					}
				}
			}
			
			// Fixed angle
			bend_default_angle[Z] = 0
			if (is_real(bendmap[?"angle"]) && array_length(axis) = 1) // Single
			{
				bend_default_angle = vec3(bendmap[?"angle"])
			}
			else if (ds_list_valid(bendmap[?"angle"])) // Multi
			{
				for (var i = 0; i < ds_list_size(bendmap[?"angle"]); i++)
					bend_default_angle[axis[i]] = ds_list_find_value(bendmap[?"angle"], i)
			}
			
			// Inherit parent bend
			bend_inherit_angle[Z] = 0
			if (bend_inherit && other.object_index = obj_model_part)
				bend_inherit_angle = point3D_add(bend_default_angle, other.bend_inherit_angle)
			else
				bend_inherit_angle = bend_default_angle
			
			ik_supported = tl_supports_ik(false)
		}
		else
		{
			bend_part = null
			bend_axis[Z] = false
			bend_direction[Z] = 0
			bend_default_angle[Z] = 0
			bend_inherit_angle[Z] = 0
			bend_inherit = false
			bend_offset = 0
			bend_end_offset = 0
			bend_size = null
			bend_invert[Z] = false
			bend_pos_offset = vec3(0)
			bend_direction_min = vec3(-180)
			bend_direction_max = vec3(180)
			ik_supported = false
		}
		
		matrix = matrix_create(point3D(0, 0, 0), rotation, vec3(1))
		
		// Matrix used when rendering preview/particle
		default_matrix = matrix_create(position, rotation, vec3(1))
		if (other.object_index = obj_model_part && lock_bend && other.bend_part != null)
			default_matrix = matrix_multiply(default_matrix, model_part_get_bend_matrix(other.id, other.bend_inherit_angle, point3D(0, 0, 0)))
		
		// Default bounds
		bounds_start = point3D(no_limit, no_limit, no_limit)
		bounds_end = point3D(-no_limit, -no_limit, -no_limit)
		
		// Whether this part contains 3D planes that need to be regenerated on texture switches
		has_3d_plane = false
		
		// Add shapes (optional)
		var shapelist = map[?"shapes"]
		if (ds_list_valid(shapelist))
		{
			shape_list = ds_list_create()
			for (var p = 0; p < ds_list_size(shapelist); p++)
			{
				var shape = model_file_load_shape(shapelist[|p], res);
				if (shape = null) // Something went wrong
					return null
				if (shape > 0)
					ds_list_add(shape_list, shape)
			}
		}
		else
			shape_list = null
		
		// Default bounds (including parts)
		bounds_parts_start = bounds_start
		bounds_parts_end = bounds_end
		
		// Recursively add parts (optional)
		var partlist = map[?"parts"]
		if (ds_list_valid(partlist))
		{
			part_list = ds_list_create()
			for (var p = 0; p < ds_list_size(partlist); p++)
			{
				var part = model_file_load_part(partlist[|p], root, res, model)
				if (part = null) // Something went wrong
					return null
				if (part > 0)
					ds_list_add(part_list, part)
			}
		}
		else
			part_list = null
		
		// Update bounds of parent
		var boundsstartdef, boundsenddef;
		boundsstartdef = point3D_mul_matrix(bounds_parts_start, default_matrix);
		boundsenddef = point3D_mul_matrix(bounds_parts_end, default_matrix);
		other.bounds_parts_start[X] = min(other.bounds_parts_start[X], boundsstartdef[X])
		other.bounds_parts_start[Y] = min(other.bounds_parts_start[Y], boundsstartdef[Y])
		other.bounds_parts_start[Z] = min(other.bounds_parts_start[Z], boundsstartdef[Z])
		other.bounds_parts_end[X]	= max(other.bounds_parts_end[X], boundsenddef[X])
		other.bounds_parts_end[Y]	= max(other.bounds_parts_end[Y], boundsenddef[Y])
		other.bounds_parts_end[Z]	= max(other.bounds_parts_end[Z], boundsenddef[Z])
		
		// Add to file list
		ds_list_add(root.file_part_list, id)
		
		// Set file to contain 3D planes
		if (has_3d_plane)
			root.has_3d_plane = true
		
		return id
	}
}
