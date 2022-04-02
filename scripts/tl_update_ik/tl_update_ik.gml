/// tl_update_ik()

function tl_update_ik()
{
	var parts, amount;
	parts = []
	amount = 0
	
	// Get body parts that have IK enabled
	with (obj_timeline)
	{
		if (type = e_tl_type.BODYPART && model_part != null && model_part.bend_part != null && model_part.bend_end_offset > 0)
		{
			// Only allow X-angle bending
			if (model_part.bend_axis[X] && !model_part.bend_axis[Y] && !model_part.bend_axis[Z])
			{
				parts[amount] = id
				amount++
			}
		}
	}
	
	// Obligatory function because IK is 'easy'
	for (var i = 0; i < array_length(parts); i++)
		do_ik(parts[i])
	
	for (var i = 0; i < array_length(parts); i++)
		with (parts[i])
			tl_update_matrix(false)
}

// Calculates FABRIK for the leaf bone and parent bones
function do_ik(tl)
{
	var jointpos, jointlength, bend, bendmat, offset, offsetpos, nobend;
	jointpos = []
	jointlength = []
	offset = tl.model_part.bend_end_offset
	offsetpos = [0, 0, 0]
	nobend = true
	
	// Calculate joint positions from body part
	with (tl)
	{
		bend = vec3(value[e_value.BEND_ANGLE_X], value[e_value.BEND_ANGLE_Y], value[e_value.BEND_ANGLE_Z])
		
		var mat = matrix_multiply(matrix_local, matrix_parent_pre_ik);
		
		// Origin
		jointpos[0] = world_pos
		
		// Middle joint
		bendmat = matrix_multiply(model_part_get_bend_matrix(model_part, bend, point3D(0, 0, 0)), mat)
		jointpos[1] = matrix_position(bendmat)
		
		// End effector
		switch (model_part.bend_part)
		{
			case e_part.UPPER: offsetpos = [0, 0, offset]; break;
			case e_part.LOWER: offsetpos = [0, 0, -offset]; break;
			case e_part.RIGHT: offsetpos = [offset, 0, 0]; break;
			case e_part.LEFT: offsetpos = [-offset, 0, 0]; break;
			case e_part.FRONT: offsetpos = [0, offset, 0]; break;
			case e_part.BACK: offsetpos = [0, -offset, 0]; break;
		}
		
		bendmat = matrix_multiply(matrix_create(offsetpos, vec3(0), vec3(1)), matrix_multiply(model_part_get_bend_matrix(model_part, bend, point3D(0, 0, 0)), mat))
		jointpos[2] = matrix_position(bendmat)
	}
	
	// Only calculate IK if target is set
	if (tl.ik_target != null)
	{
		// Calculate lengths of bones between joints
		jointlength[0] = point3D_distance(jointpos[0], jointpos[1])
		jointlength[1] = point3D_distance(jointpos[1], jointpos[2])
		jointlength[2] = 0
		
		// Check for inverted part
		if (!tl.model_part.bend_invert[X])
		{
			jointpos[1] = point3D_add(jointpos[0], vec3_mul(point3D_sub(jointpos[0], jointpos[1]), 1))
			jointpos[2] = point3D_add(jointpos[0], vec3_mul(point3D_sub(jointpos[0], jointpos[2]), 1))
		}
		
		// Is the target position of out range?
		if (point3D_distance(jointpos[0], tl.ik_target.world_pos) > (jointlength[0] + jointlength[1]))
		{
			var dir = vec3_direction(jointpos[0], tl.ik_target.world_pos);
			
			for (i = 1; i < array_length(jointpos); i++)
				jointpos[i] = point3D_add(jointpos[i - 1], vec3_mul(dir, jointlength[i - 1]))
		}
		else // Calculate inverse kinematics (FABRIK)
		{
			var dis = point3D_distance(jointpos[0], tl.ik_target.world_pos);
			
			for (var t = 0; t < 30 && (dis > 0.01); t++)
			{
				// Backwards
				for (var i = array_length(jointpos) - 1; i > 0; i--)
				{
					// Set last joint at target
					if (i = array_length(jointpos) - 1)
						jointpos[i] = tl.ik_target.world_pos
					else // Get angle between between previous point and the current point's last position and adjust
						jointpos[i] = point3D_add(jointpos[i + 1], vec3_mul(vec3_direction(jointpos[i + 1], jointpos[i]), jointlength[i]))
				}
				
				// Forwards
				for (var i = 1; i < array_length(jointpos); i++)
					jointpos[i] = point3D_add(jointpos[i - 1], vec3_mul(vec3_direction(jointpos[i - 1], jointpos[i]), jointlength[i - 1]))
				
				// Update distance
				dis = point3D_distance(jointpos[0], tl.ik_target.world_pos)
			}
			
			nobend = false
		}
	}
	
	// Get positions/directions
	var p0, p1, p2, p0proj, p1proj, p2proj, ab, bc, ac, n;
	p0 = jointpos[0]
	p1 = jointpos[1]
	p2 = jointpos[2]
	ab = vec3_direction(p0, p1)
	bc = vec3_direction(p1, p2)
	ac = vec3_direction(p0, p2)
	
	// Apply pole target rotation to second joint (if bending)
	if (tl.ik_pole_target != null && !nobend)
	{
		var poleproj, angle;
		poleproj = point3D_project_plane(tl.ik_pole_target.world_pos, p0, ac)
		p1proj = point3D_project_plane(p1, p0, ac)
		angle = point3D_angle_signed(point3D_sub(p1proj, p0), point3D_sub(poleproj, p0), ac)
		
		p1 = point3D_add(p0, vec3_rotate_axis_angle(point3D_sub(p1, p0), ac, degtorad(angle)))
		
		// Update directions
		ab = vec3_direction(p0, p1)
		bc = vec3_direction(p1, p2)
	}
	
	// Get front-facing direction
	if (tl.ik_pole_target = null && nobend)
	{
		// No pole target and straight, use arbitrary direction
		n = vec3_normal(ab, 0)
	}
	else
	{
		if (tl.ik_pole_target != null && nobend) // Uses pole target & no bending present
			p2proj = point3D_project_plane(tl.ik_pole_target.world_pos, p0, ab)
		else
			p2proj = point3D_project_plane(p2, p0, ab)
		
		n = vec3_direction(p2proj, p0)
		
		// Flip direction based on invert
		if (tl.model_part.bend_invert[X])
			n = vec3_mul(n, -1)
		
		if (tl.ik_pole_target != null && nobend)
			n = vec3_mul(n, -1)
	}
	
	// First joint
	tl.part_joints_pos[0] = p0
	tl.part_joints_matrix[0] = matrix_create_rotate_to(n, vec3_mul(ab, -1))
	tl.part_joints_bone_matrix[0] = matrix_create_rotate_to(n, ab)
	
	// Second joint
	if (!nobend)
	{
		p0proj = point3D_project_plane(p0, p1, bc)
		n = vec3_direction(p1, p0proj)
	}
	
	tl.part_joints_pos[1] = p1
	tl.part_joints_matrix[1] = matrix_create_rotate_to(n, vec3_mul(bc, -1))
	tl.part_joints_bone_matrix[1] = matrix_create_rotate_to(n, bc)
	
	// Third joint (Not *needed*, but just in case...)
	tl.part_joints_pos[2] = p2
	tl.part_joints_matrix[2] = tl.part_joints_matrix[1]
	tl.part_joints_bone_matrix[2] = tl.part_joints_bone_matrix[1]
	
	// Bend angle
	tl.part_joint_bend_angle = radtodeg(arccos(vec3_dot(ab, bc)))
	
	// Update matrix
	tl.update_matrix = true
	
	return 0
}