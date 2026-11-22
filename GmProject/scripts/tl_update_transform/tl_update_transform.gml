/// CppGen matrix transformmatrix
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
			matrix_parent = matrix_copy(parent.matrix_render)
		else
			matrix_parent = matrix_copy(parent.matrix)
		
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
			var offset, curpos, mat;
			offset = value[e_value.PATH_OFFSET]
		
			// Get current position
			curpos = tl_path_offset_get_position(path, offset)
		
			// Make rotation matrix and add path position
			var n, t;
			n = vec3_normalize(vec3(curpos[PATH_NORMAL_X], curpos[PATH_NORMAL_Y], curpos[PATH_NORMAL_Z]))
			t = vec3_normalize(vec3(curpos[PATH_TANGENT_X], curpos[PATH_TANGENT_Y], curpos[PATH_TANGENT_Z]))
		
			mat = matrix_create_rotate_to(t, n)
		
			// If path is closed, check if object is before/after ends
			if (!path.path_closed)
			{
				if (offset <= 0)
					curpos = tl_path_offset_get_position(path, 0)
				else if (offset >= path.path_length)
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
		partpos = point3D(0)
		if (part_of != null)
			partpos = point3D(model_part.position[X], model_part.position[Y], model_part.position[Z])
		partrot = point3D(model_part.rotation[X], model_part.rotation[Y], model_part.rotation[Z])
		partchanged = (!transform_part_cache_valid || transform_part_cache_id != model_part)
		for (var j = X; j <= Z; j++)
			if (partpos[j] != transform_part_cache_pos[j] || partrot[j] != transform_part_cache_rot[j])
				partchanged = true
		if (partchanged)
		{
			transform_part_cache_matrix = matrix_create(partpos, partrot, vec3(1))
			transform_part_cache_pos = partpos
			transform_part_cache_rot = partrot
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
		transform_local_pos = pos
		transform_local_rot = rot
		transform_local_scale = sca
		transform_local_cache_valid = true
	}
	var transformmatrix = matrix_multiply(matrix_local, matrix_parent);
	
	// Remove old rotation and re-add own
	if (!inherit_rotation)
	{
		matrix_remove_rotation(transformmatrix)
		transformmatrix = matrix_multiply(matrix_create(point3D(0), rot, vec3(1)), transformmatrix)
	}
	
	// Get current matrix for IK
	matrix_parent_pre_ik = matrix_copy(transformmatrix)
	
	// Add IK orientation
	if (hasik)
		transformmatrix = matrix_multiply(part_joints_matrix[0], transformmatrix)
	
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
			transformmatrix = matrix_multiply(posetl.matrix_local, transformmatrix)
			
			// Bend
			for (var j = X; j <= Z; j++)
				posebend[j] = posetl.value_inherit[e_value.BEND_ANGLE_X + j]
			
			// IK
			if (array_length(posetl.part_joints_matrix) > 0 && posetl.value[e_value.IK_TARGET] != null)
				transformmatrix = matrix_multiply(posetl.part_joints_matrix[0], transformmatrix)
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
		parmat = matrix_copy(matrix_parent)
		
		// Remove rotation
		if (!inherit_rotation)
			matrix_remove_rotation(parmat)
		
		matrixnoscale = matrix_multiply(matrix_create(pos, rot, vec3(1)), parmat)
		
		if (hasik)
			matrixnoscale = matrix_multiply(part_joints_matrix[0], matrixnoscale)
		
		for (var p = 0; p < 11; p++)
			transformmatrix[p] = matrixnoscale[p]
		
		// Re-add calculated or own scale
		if (inherit_scale)
			transformmatrix = matrix_multiply(matrix_create(point3D(0), vec3(0), sca), transformmatrix)
		else
			transformmatrix = matrix_multiply(matrix_create(point3D(0), vec3(0), vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])), transformmatrix)
	}
	
	// Replace position
	if (!inherit_position)
	{
		matrix_remove_rotation(matrix_parent)
		transformmatrix[MAT_X] = value[e_value.POS_X]
		transformmatrix[MAT_Y] = value[e_value.POS_Y]
		transformmatrix[MAT_Z] = value[e_value.POS_Z]
	}
	
	// Create rotation point
	if (type = e_tl_type.CAMERA && value[e_value.CAM_ROTATE])
	{
		world_pos_rotate = matrix_position(transformmatrix)
		transformmatrix[MAT_X] += lengthdir_x(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_XY] + 90) * lengthdir_x(1, value[e_value.CAM_ROTATE_ANGLE_Z])
		transformmatrix[MAT_Y] += lengthdir_y(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_XY] + 90) * lengthdir_x(1, value[e_value.CAM_ROTATE_ANGLE_Z])
		transformmatrix[MAT_Z] += lengthdir_z(value[e_value.CAM_ROTATE_DISTANCE], value[e_value.CAM_ROTATE_ANGLE_Z])
	}
	
	// Set world position
	world_pos = matrix_position(transformmatrix)
	matrix = transformmatrix
	
	// Add rotation point
	matrix_render = matrix_multiply(matrix_create(point3D_mul(rot_point_render, -1), vec3(0), vec3(1)), transformmatrix)
	
	return posebend
}
