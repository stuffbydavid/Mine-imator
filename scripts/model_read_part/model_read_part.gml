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

if (!is_real(map[?"position"]) || !ds_exists(map[?"position"], ds_type_list))
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
		texture = map[?"texture"]
		
		// Texture size
		if (!is_real(map[?"texture_size"]) || !ds_exists(map[?"texture_size"], ds_type_list))
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
		texture = other.texture
		texture_size = other.texture_size
	}
	
	// Position
	var pos = map[?"position"]
	position = point3D(pos[|X], pos[|Z], pos[|Y])
	
	// Rotation (optional)
	var rotlist = map[?"rotation"]
	if (is_real(rotlist) && ds_exists(rotlist, ds_type_list))
		rotation = vec3(rotlist[|X], rotlist[|Z], rotlist[|Y])
	else
		rotation = vec3(0, 0, 0)
		
	// Scale (optional)
	var scalelist = map[?"scale"]
	if (is_real(scalelist) && ds_exists(scalelist, ds_type_list))
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
				case e_part.UPPER:
					if (position[Z] > other.bend_offset)
						position[Z] -= other.bend_offset
					break
			}
		}
	}
		
	// Matrix used when rendering
	matrix = matrix_create(position, rotation, scale)
		
	// Default bounds and matrix
	bounds_start = point3D(0, 0, 0)
	bounds_end = point3D(0, 0, 0)
	if (other.object_index = obj_model_part)
	{
		if (lock_bend && other.bend_part != null)
			default_matrix = matrix_multiply(matrix, matrix_multiply(model_bend_matrix(other.id, 0), other.default_matrix))
		else
			default_matrix = matrix_multiply(matrix, other.default_matrix)
	}
	else
		default_matrix = matrix
		
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
	
	// Add shapes (optional)
	var shapelist = map[?"shapes"]
	if (is_real(shapelist) && ds_exists(shapelist, ds_type_list))
	{
		shape_vbuffer = vbuffer_start()
		if (bend_part != null)
			shape_bend_vbuffer = vbuffer_start()
			
		shape_amount = ds_list_size(shapelist)
		for (var p = 0; p < shape_amount; p++)
		{
			shape[p] = model_read_shape(shapelist[|p])
			if (shape[p] = null) // Something went wrong
			{
				log("Could not read shape list", name)
				vbuffer_done(shape_vbuffer)
				if (bend_part != null)
					vbuffer_done(shape_bend_vbuffer)
				shape_vbuffer = null
				return null
			}
		}
		vbuffer_done(shape_vbuffer)
		if (bend_part != null)
			vbuffer_done(shape_bend_vbuffer)
	}
	else
	{
		shape_amount = 0
		shape_vbuffer = null
	}
	
	// Recursively add parts (optional)
	var partlist = map[?"parts"]
	if (is_real(partlist) && ds_exists(partlist, ds_type_list))
	{
		part_amount = ds_list_size(partlist)
		for (var p = 0; p < part_amount; p++)
		{
			part[p] = model_read_part(partlist[|p], root)
			if (part[p] = null) // Something went wrong
			{
				log("Could not read part list", name)
				return null
			}
		}
	}
	else
		part_amount = 0
		
	// Update bounds
	other.bounds_start[X] = min(other.bounds_start[X], bounds_start[X])
	other.bounds_start[Y] = min(other.bounds_start[Y], bounds_start[Y])
	other.bounds_start[Z] = min(other.bounds_start[Z], bounds_start[Z])
	other.bounds_end[X] = max(other.bounds_end[X], bounds_end[X])
	other.bounds_end[Y] = max(other.bounds_end[Y], bounds_end[Y])
	other.bounds_end[Z] = max(other.bounds_end[Z], bounds_end[Z])
	
	// Add to file list
	ds_list_add(root.file_part_list, id)
		
	return id
}