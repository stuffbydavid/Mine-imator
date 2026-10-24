/// CppSeparate VecType tl_update_transform(Scope<obj_timeline>, BoolType, BoolType, BoolType)
/// @desc Evaluates timeline transforms and returns inherited pose bending
/// @arg usepaths
/// @arg updatepose
/// @arg hasik

function tl_update_transform(usepaths, updatepose, hasik)
{
	// Get parent matrix
	if (parent != app)
	{
		if (inherit_rot_point)
			matrix_parent = array_copy_1d(parent.matrix_render)
		else
			matrix_parent = array_copy_1d(parent.matrix)
		
		// Parent is a body part and we're locked to bended half
		if (parent.type = e_tl_type.MODEL_PART && lock_bend && parent.model_part != null && parent.model_part.bend_part != null)
		{
			var bend = vec3(
				parent.value_inherit[e_value.BEND_ANGLE_X],
				parent.value_inherit[e_value.BEND_ANGLE_Y],
				parent.value_inherit[e_value.BEND_ANGLE_Z]
			);
			matrix_parent = matrix_multiply(model_part_get_bend_matrix(parent.model_part, bend, point3D(0)), matrix_parent)
		}
	}
	else
		matrix_parent = MAT_IDENTITY
	
	// Orient to path object
	if (usepaths)
	{
		var path = value[e_value.PATH_OBJ];
		if (path != null && array_length(path.path_table) > 0)
		{
			var offset, angle, curpos, mat;
			offset = value[e_value.PATH_OFFSET]
			angle = 0
		
			// Get current position
			curpos = tl_path_offset_get_position(path, offset)
		
			// Make rotation matrix and add path position
			var n, t;
			n = vec3_normalize([ curpos[PATH_NORMAL_X], curpos[PATH_NORMAL_Y], curpos[PATH_NORMAL_Z] ])
			t = vec3_normalize([ curpos[PATH_TANGENT_X], curpos[PATH_TANGENT_Y], curpos[PATH_TANGENT_Z] ])
		
			mat = matrix_create_rotate_to(t, n)
		
			// If path is closed, check if object is before/after ends
			if (!path.path_closed)
			{
				if (value[e_value.PATH_OFFSET] <= 0)
					curpos = tl_path_offset_get_position(path, 0)
				else if (value[e_value.PATH_OFFSET] >= path.path_length)
					curpos = tl_path_offset_get_position(path, path.path_length)
			}
		
			mat = matrix_multiply(mat, matrix_create(curpos, vec3(0), vec3(1)))
		
			matrix_parent = matrix_multiply(matrix_parent, mat)
		
			if (is_array(path.matrix))
				matrix_parent = matrix_multiply(matrix_parent, path.matrix)
		}
	}
	
	// Add body part position and rotation
	if (type = e_tl_type.MODEL_PART && model_part != null)
	{
		var partpos, partrot, partchanged;
		partpos = (part_of != null ? model_part.position : point3D(0))
		partrot = model_part.rotation
		partchanged = (!transform_part_cache_valid || transform_part_cache_id != model_part)
		for (var j = X; j <= Z; j++)
			if (partpos[j] != transform_part_cache_pos[j] || partrot[j] != transform_part_cache_rot[j])
				partchanged = true
		if (partchanged)
		{
			transform_part_cache_matrix = matrix_create(partpos, partrot, vec3(1))
			transform_part_cache_pos = array_copy_1d(partpos)
			transform_part_cache_rot = array_copy_1d(partrot)
			transform_part_cache_id = model_part
			transform_part_cache_valid = true
		}
		matrix_parent = matrix_multiply(transform_part_cache_matrix, matrix_parent)
	}
	
	// Create main matrix
	var pos, rot, sca;
	pos = point3D(value[e_value.POS_X], value[e_value.POS_Y], value[e_value.POS_Z])
	rot = vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z])
	sca = vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])
	
	var localchanged = !transform_local_cache_valid;
	for (var j = X; j <= Z; j++)
		if (pos[j] != transform_local_pos[j] || rot[j] != transform_local_rot[j] || sca[j] != transform_local_scale[j])
			localchanged = true
	if (localchanged)
	{
		matrix_local = matrix_create(pos, rot, sca)
		transform_local_pos = array_copy_1d(pos)
		transform_local_rot = array_copy_1d(rot)
		transform_local_scale = array_copy_1d(sca)
		transform_local_cache_valid = true
	}
	matrix = matrix_multiply(matrix_local, matrix_parent)
	
	// Remove old rotation and re-add own
	if (!inherit_rotation)
	{
		matrix_remove_rotation(matrix)
		matrix = matrix_multiply(matrix_create(point3D(0), vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z]), vec3(1)), matrix)
	}
	
	// Get current matrix for IK
	matrix_parent_pre_ik = array_copy_1d(matrix)
	
	// Add IK orientation
	if (hasik)
		matrix = matrix_multiply(part_joints_matrix[0], matrix)
	
	// Check body part model timeline is "Inherit pose" is enabled, look at parent of root model and search for matching body parts to inherit from
	var posebend = vec3(0);
	if (updatepose && part_of != null && part_of.inherit_pose && part_of.parent != app)
	{
		var posetl = null;
		with (part_of.parent)
			posetl = tl_part_find(other.model_part_name)
		
		if (posetl != null)
		{
			// Local orientation
			matrix = matrix_multiply(posetl.matrix_local, matrix)
			
			// Bend
			for (var j = X; j <= Z; j++)
				posebend[j] = posetl.value_inherit[e_value.BEND_ANGLE_X + j]
			
			// IK
			if (array_length(posetl.part_joints_matrix) > 0 && posetl.value[e_value.IK_TARGET] != null)
				matrix = matrix_multiply(posetl.part_joints_matrix[0], matrix)
		}
	}
	
	// No scale or "resize" mode
	if (scale_resize || !inherit_scale || type = e_tl_type.PARTICLE_SPAWNER)
	{
		// Get actual scale
		var tl = id;
		while (true)
		{
			var par = tl.parent;
			if (!tl.inherit_scale || par = app)
				break
			
			sca = vec3_mul(sca, vec3(par.value[e_value.SCA_X], par.value[e_value.SCA_Y], par.value[e_value.SCA_Z]))
			tl = par
		}
		
		// Remove scale
		var parmat, matrixnoscale;
		matrix_remove_scale(matrix_parent)
		parmat = array_copy_1d(matrix_parent)
		
		// Remove rotation
		if (!inherit_rotation)
			matrix_remove_rotation(parmat)
		
		matrixnoscale = matrix_multiply(matrix_create(pos, rot, vec3(1)), parmat)
		
		if (hasik)
			matrixnoscale = matrix_multiply(part_joints_matrix[0], matrixnoscale)
		
		for (var p = 0; p < 11; p++)
			matrix[p] = matrixnoscale[p]
		
		// Re-add calculated or own scale
		if (inherit_scale)
			matrix = matrix_multiply(matrix_create(point3D(0), vec3(0), sca), matrix)
		else
			matrix = matrix_multiply(matrix_create(point3D(0), vec3(0), vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])), matrix) 
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
	matrix_render = matrix_multiply(matrix_create(point3D_mul(rot_point_render, -1), vec3(0), vec3(1)), matrix)
	
	return posebend
}
