/// model_file_load_part(map, root, resource)
/// @arg map
/// @arg root
/// @arg resource
/// @desc Adds a part from the given map (JSON object) and returns its instance.

var map, root, res;
map = argument0
root = argument1
res = argument2

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
	
with (new(obj_model_part))
{
	// Name
	name = map[?"name"]
	
	if (res = null && dev_mode_debug_names && !text_exists("modelpart" + name))
		log("model/part/" + name + dev_mode_name_translation_message)
	
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
	
	// Position
	position_noscale = value_get_point3D(map[?"position"])
	position = point3D_mul(position_noscale, other.scale)
	
	show_position = false
	if (is_real(map[?"show_position"]))
		show_position = map[?"show_position"]
		
	// Rotation (optional)
	rotation = value_get_point3D(map[?"rotation"], vec3(0, 0, 0))
		
	// Scale (optional)
	scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
	scale = vec3_mul(scale, other.scale)
	
	// Locked to parent bend half?
	lock_bend = true
	if (other.object_index = obj_model_part && other.bend_part != null)
	{
		if (is_real(map[?"lock_bend"]))
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
		
	matrix = matrix_create(point3D(0, 0, 0), rotation, vec3(1))
	
	// Matrix used when rendering preview/particle
	default_matrix = matrix_create(position, rotation, vec3(1))
	if (other.object_index = obj_model_part && lock_bend && other.bend_part != null)
		default_matrix = matrix_multiply(default_matrix, model_part_get_bend_matrix(other.id, 0, point3D(0, 0, 0)))
	
	// Bend (optional)
	if (!is_undefined(map[?"bend"]))
	{
		var bendmap = map[?"bend"]
		
		// Offset
		if (!is_real(bendmap[?"offset"]))
		{
			log("Missing parameter \"offset\"")
			return null
		}
		bend_offset = bendmap[?"offset"]
		
		// Part
		if (!is_string(bendmap[?"part"])) 
		{
			log("Missing parameter \"part\"")
			return null
		}
		
		// Size
		bend_size = value_get_real(bendmap[?"size"], 4)
		
		switch (bendmap[?"part"])
		{
			case "right":	bend_part = e_part.RIGHT;	bend_offset *= scale[X];	bend_size *= scale[X];	break
			case "left":	bend_part = e_part.LEFT;	bend_offset *= scale[X];	bend_size *= scale[X];	break
			case "front":	bend_part = e_part.FRONT;	bend_offset *= scale[Y];	bend_size *= scale[Y];	break
			case "back":	bend_part = e_part.BACK;	bend_offset *= scale[Y];	bend_size *= scale[Y];	break
			case "upper":	bend_part = e_part.UPPER;	bend_offset *= scale[Z];	bend_size *= scale[Z];	break
			case "lower":	bend_part = e_part.LOWER;	bend_offset *= scale[Z];	bend_size *= scale[Z];	break
			default:
				log("Invalid parameter \"part\"")
				return null
		}
			
		// Axis
		if (!is_string(bendmap[?"axis"]))
		{
			log("Missing parameter \"axis\"")
			return null
		}
		
		switch (bendmap[?"axis"])
		{
			case "x":	bend_axis = X;	break
			case "y":	bend_axis = Z;	break
			case "z":	bend_axis = Y;	break
			default:
				log("Invalid parameter \"axis\"")
				return null
		}
		
		// Direction
		if (!is_string(bendmap[?"direction"]))
		{
			log("Missing parameter \"direction\"")
			return null
		}
		
		switch (bendmap[?"direction"])
		{
			case "forward":		bend_direction = e_bend.FORWARD;	break
			case "backward":	bend_direction = e_bend.BACKWARD;	break
			case "both":		bend_direction = e_bend.BOTH;		break
			default:
				log("Invalid parameter \"direction\"")
				return null
		}
		
		// Invert
		bend_invert = value_get_real(bendmap[?"invert"], false)
	}
	else
	{
		bend_part = null
		bend_axis = null
		bend_direction = null
		bend_offset = 0
		bend_size = 4
		bend_invert = false
	}
	
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
			var part = model_file_load_part(partlist[|p], root, res)
			if (part = null) // Something went wrong
				return null
			ds_list_add(part_list, part)
		}
	}
	else
		part_list = null
		
	// Update bounds of parent
	var boundsstartdef, boundsenddef;
	boundsstartdef = point3D_mul_matrix(bounds_parts_start, default_matrix);
	boundsenddef   = point3D_mul_matrix(bounds_parts_end, default_matrix);
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