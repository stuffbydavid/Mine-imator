/// tl_update_matrix()
/// @desc Updates matrixes and positions.

if (object_index != app && update_matrix)
{
	// Get parent matrix
	if (parent != app)
	{
		if (inherit_rot_point)
			matrix_parent = array_copy_1d(parent.matrix_render)
		else
			matrix_parent = array_copy_1d(parent.matrix)
			
		// Parent is a body part and we're locked to bended half
		if (parent.type = e_tl_type.BODYPART && lock_bend && parent.model_part != null)
			matrix_parent = matrix_multiply(model_part_get_bend_matrix(parent.model_part, parent.value_inherit[e_value.BEND_ANGLE], point3D(0, 0, 0)), matrix_parent)
	}
	else
		matrix_parent = MAT_IDENTITY
		
	// Add body part position and rotation
	if (type = e_tl_type.BODYPART && model_part != null)
	{
		if (part_of != null)
			matrix_parent = matrix_multiply(matrix_create(model_part.position, model_part.rotation, vec3(1)), matrix_parent)
		else
			matrix_parent = matrix_multiply(matrix_create(point3D(0, 0, 0), model_part.rotation, vec3(1)), matrix_parent)
	}
		
	// Create main matrix
	var pos, rot, sca, tl;
	pos = point3D(value[e_value.POS_X], value[e_value.POS_Y], value[e_value.POS_Z])
	rot = vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z])
	sca = vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])
	matrix = matrix_multiply(matrix_create(pos, rot, sca), matrix_parent)
		
	// No scale or "resize" mode
	if (scale_resize || !inherit_scale)
	{
		// Get actual scale
		tl = id
		
		while (true)
		{
			var par = tl.parent;
			if (!tl.inherit_scale || par = app)
				break
			sca = vec3_mul(sca, vec3(par.value[e_value.SCA_X], par.value[e_value.SCA_Y], par.value[e_value.SCA_Z]))
			tl = par
		}
		
		// Remove scale
		matrix_remove_scale(matrix_parent)
		var matrixnoscale = matrix_multiply(matrix_create(pos, rot, vec3(1)), matrix_parent);
		for (var p = 0; p < 11; p++)
			matrix[p] = matrixnoscale[p]
		
		// Re-add calculated or own scale
		if (inherit_scale)
			matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(0), sca), matrix)
		else
			matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(0), vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])), matrix) 
	}
	
	// Remove old rotation and re-add own
	if (!inherit_rotation)
	{
		matrix_remove_rotation(matrix)
		matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z]), vec3(1)), matrix) 
	}
	
	// Replace position
	if (!inherit_position)
	{
		matrix_remove_rotation(matrix_parent)
		matrix[MAT_X] = value[e_value.POS_X]
		matrix[MAT_Y] = value[e_value.POS_Y]
		matrix[MAT_Z] = value[e_value.POS_Z]
	}
	
	// Create rotation point
	if (type = e_tl_type.CAMERA && value[e_value.CAM_ROTATE])
	{
		world_pos_rotate = point3D(matrix[MAT_X], matrix[MAT_Y], matrix[MAT_Z])
		matrix[MAT_X] += lengthdir_x(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_XY] + 90) * lengthdir_x(1, value[e_value.CAM_ROTATE_ANGLE_Z])
		matrix[MAT_Y] += lengthdir_y(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_XY] + 90) * lengthdir_x(1, value[e_value.CAM_ROTATE_ANGLE_Z])
		matrix[MAT_Z] += lengthdir_z(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_Z])
	}
	
	// Set world position
	world_pos = point3D(matrix[MAT_X], matrix[MAT_Y], matrix[MAT_Z])
	
	// Add rotation point
	matrix_render = matrix_multiply(matrix_create(point3D_mul(rot_point, -1), vec3(0), vec3(1)), matrix)
	
	// Scale for position controls
	value_inherit[e_value.SCA_X] = 1
	value_inherit[e_value.SCA_Y] = 1
	value_inherit[e_value.SCA_Z] = 1
	tl = id
	while (1)
	{
		var par = tl.parent;
		if (par = app)
			break
			
		value_inherit[e_value.SCA_X] *= par.value[e_value.SCA_X]
		value_inherit[e_value.SCA_Y] *= par.value[e_value.SCA_Y]
		value_inherit[e_value.SCA_Z] *= par.value[e_value.SCA_Z]
		
		if (!par.inherit_scale)
			break
		tl = par
	}
	
	// Inherit
	var lasttex = value[e_value.TEXTURE_OBJ];
	value_inherit[e_value.ALPHA] = value[e_value.ALPHA] // Multiplied
	value_inherit[e_value.RGB_ADD] = value[e_value.RGB_ADD] // Added
	value_inherit[e_value.RGB_SUB] = value[e_value.RGB_SUB] // Added
	value_inherit[e_value.RGB_MUL] = value[e_value.RGB_MUL] // Multiplied
	value_inherit[e_value.HSB_ADD] = value[e_value.HSB_ADD] // Added
	value_inherit[e_value.HSB_SUB] = value[e_value.HSB_SUB] // Added
	value_inherit[e_value.HSB_MUL] = value[e_value.HSB_MUL] // Multiplied
	value_inherit[e_value.MIX_COLOR] = value[e_value.MIX_COLOR] // Added
	value_inherit[e_value.MIX_PERCENT] = value[e_value.MIX_PERCENT] // Added
	value_inherit[e_value.BRIGHTNESS] = value[e_value.BRIGHTNESS] // Added
	value_inherit[e_value.VISIBLE] = value[e_value.VISIBLE] // Multiplied
	value_inherit[e_value.BEND_ANGLE] = value[e_value.BEND_ANGLE] // Added
	value_inherit[e_value.TEXTURE_OBJ] = value[e_value.TEXTURE_OBJ] // Overwritten
	
	var inhalpha, inhcolor, inhvis, inhbend, inhtex;
	inhalpha = true
	inhcolor = true
	inhvis = true
	inhbend = true
	inhtex = true
	tl = id
	while (true)
	{
		var par = tl.parent;
		if (par = app)
			break
		
		if (!tl.inherit_alpha)
			inhalpha = false
		
		if (!tl.inherit_color)
			inhcolor = false
		
		if (!tl.inherit_visibility)
			inhvis = false
		
		if (!tl.inherit_bend)
			inhbend = false
		
		if (!tl.inherit_texture || tl.value[e_value.TEXTURE_OBJ] > 0)
			inhtex = false
		
		if (inhalpha)
			value_inherit[e_value.ALPHA] *= par.value[e_value.ALPHA]
			
		if (inhcolor)
		{
			value_inherit[e_value.RGB_ADD] = color_add(value_inherit[e_value.RGB_ADD], par.value[e_value.RGB_ADD])
			value_inherit[e_value.RGB_SUB] = color_add(value_inherit[e_value.RGB_SUB], par.value[e_value.RGB_SUB])
			value_inherit[e_value.RGB_MUL] = color_multiply(value_inherit[e_value.RGB_MUL], par.value[e_value.RGB_MUL])
			value_inherit[e_value.HSB_ADD] = color_add(value_inherit[e_value.HSB_ADD], par.value[e_value.HSB_ADD])
			value_inherit[e_value.HSB_SUB] = color_add(value_inherit[e_value.HSB_SUB], par.value[e_value.HSB_SUB])
			value_inherit[e_value.HSB_MUL] = color_multiply(value_inherit[e_value.HSB_MUL], par.value[e_value.HSB_MUL])
			value_inherit[e_value.MIX_COLOR] = color_add(value_inherit[e_value.MIX_COLOR], par.value[e_value.MIX_COLOR])
			value_inherit[e_value.MIX_PERCENT] = clamp(value_inherit[e_value.MIX_PERCENT] + par.value[e_value.MIX_PERCENT], 0, 1)
			value_inherit[e_value.BRIGHTNESS] = clamp(value_inherit[e_value.BRIGHTNESS] + par.value[e_value.BRIGHTNESS], 0, 1)
		}
		
		if (inhvis)
			value_inherit[e_value.VISIBLE] *= par.value[e_value.VISIBLE]
			
		if (inhbend)
			value_inherit[e_value.BEND_ANGLE] += par.value[e_value.BEND_ANGLE]
			
		if (inhtex)
			value_inherit[e_value.TEXTURE_OBJ] = par.value[e_value.TEXTURE_OBJ]
			
		tl = par
	}
	
	colors_ext = (value_inherit[e_value.ALPHA] < 1 ||
				  value_inherit[e_value.RGB_ADD] - value_inherit[e_value.RGB_SUB] != c_black ||
				  value_inherit[e_value.HSB_ADD] - value_inherit[e_value.HSB_SUB] != c_black ||
				  value_inherit[e_value.HSB_MUL] < c_white ||
				  value_inherit[e_value.MIX_PERCENT] > 0)
	
	// Update bend vbuffer
	tl_update_bend()
	
	// Texture change, update planes
	if (lasttex != value[e_value.TEXTURE_OBJ])
		tl_update_part_plane_vbuffer_map()
}

// Update children
for (var t = 0; t < ds_list_size(tree_list); t++)
{
	if (object_index != app && update_matrix)
		tree_list[|t].update_matrix = true
	
	with (tree_list[|t])
		tl_update_matrix()
}

update_matrix = false
