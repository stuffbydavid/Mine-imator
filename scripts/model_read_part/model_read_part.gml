/// model_read_part(map, root)
/// @arg map
/// @arg root
/// @desc Adds a part from the given map (JSON object), returns its instance

var map, root;
map = argument0
root = argument1

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

with (new(obj_model_part))
{
	// Name
	if (is_string(map[?"name"]))
		name = map[?"name"]
	else
	{
		log("Missing parameter \"name\"")
		return null
	}
	
	// Description (optional)
	if (is_string(map[?"description"]))
		description = map[?"description"]
	else
		description = ""
		
	// Texture (optional)
	if (is_string(map[?"texture"]))
	{
		texture_name = map[?"texture"]
		
		// Texture size
		if (!ds_list_valid(map[?"texture_size"]))
		{
			log("Missing array \"texture_size\"")
			return null
		}
		
		var texturesizelist = map[?"texture_size"];
		texture_size = vec2(texturesizelist[|X], texturesizelist[|Y])
	}
	else
	{
		// Inherit
		texture_name = other.texture_name
		texture_size = other.texture_size
	}
	
	// Position
	var pos = map[?"position"]
	position = point3D(pos[|X], pos[|Z], pos[|Y])
	
	// Rotation (optional)
	var rotlist = map[?"rotation"]
	if (ds_list_valid(rotlist))
		rotation = vec3(rotlist[|X], rotlist[|Z], rotlist[|Y])
	else
		rotation = vec3(0, 0, 0)
		
	// Scale (optional)
	var scalelist = map[?"scale"]
	if (ds_list_valid(scalelist))
		scale = vec3(scalelist[|X], scalelist[|Z], scalelist[|Y])
	else
		scale = vec3(1, 1, 1)
		
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
	
	matrix = matrix_create(point3D(0, 0, 0), rotation, scale)
		
	// Matrix used when rendering preview/particle
	default_matrix = matrix_create(position, rotation, scale)
	if (other.object_index = obj_model_part && lock_bend && other.bend_part != null)
		default_matrix = matrix_multiply(default_matrix, model_part_bend_matrix(other.id, 0))
	
	// Bend (optional)
	if (!is_undefined(map[?"bend"]))
	{
		var bendmap = map[?"bend"]
		
		// Part
		if (!is_string(bendmap[?"part"])) 
		{
			log("Missing parameter \"part\"")
			return null
		}
		
		switch (bendmap[?"part"])
		{
			case "right":	bend_part = e_part.RIGHT;	break
			case "left":	bend_part = e_part.LEFT;	break
			case "front":	bend_part = e_part.FRONT;	break
			case "back":	bend_part = e_part.BACK;	break
			case "upper":	bend_part = e_part.UPPER;	break
			case "lower":	bend_part = e_part.LOWER;	break
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
		
		// Offset
		if (!is_real(bendmap[?"offset"]))
		{
			log("Missing parameter \"offset\"")
			return null
		}
		bend_offset = bendmap[?"offset"]
	}
	else
	{
		bend_part = null
		bend_axis = null
		bend_direction = null
		bend_offset = 0
	}
	
	// Default bounds
	bounds_start = point3D(no_limit, no_limit, no_limit)
	bounds_end = point3D(-no_limit, -no_limit, -no_limit)
	
	// Add shapes (optional)
	var shapelist = map[?"shapes"]
	if (ds_list_valid(shapelist))
	{
		shape_list = ds_list_create()
		for (var p = 0; p < ds_list_size(shapelist); p++)
		{
			var shape = model_read_shape(shapelist[|p]);
			if (shape = null) // Something went wrong
			{
				log("Could not read shape list", name)
				return null
			}
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
			var part = model_read_part(partlist[|p], root)
			if (part = null) // Something went wrong
			{
				log("Could not read part list", name)
				return null
			}
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
		
	return id
}