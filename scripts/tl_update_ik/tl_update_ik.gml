/// tl_update_ik()

function tl_update_ik()
{
	var parts, amount, update;
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
	
	// Recursivly update IK data, break if positions are done moving
	repeat (8)
	{
		update = false
		
		// Obligatory function because IK is 'easy'
		for (var i = 0; i < array_length(parts); i++)
			do_ik(parts[i])
		
		for (var i = 0; i < array_length(parts); i++)
		{
			with (parts[i])
			{
				if (update_matrix)
				{
					update = true
					ik_world_pos_prev = world_pos
					tl_update_matrix(false)
				}
			}
		}
		
		if (!update)
			break
	}
}

// Calculates FABRIK for the leaf bone and parent bones
function do_ik(tl)
{
	var jointpos, jointlength, bend, bendmat, offset, offsetpos, nobend, endpos, haspole, polepos;
	jointpos = []
	jointlength = []
	offset = tl.model_part.bend_end_offset
	offsetpos = [0, 0, 0]
	nobend = true
	endpos = [0, 0, 0]
	
	// Do we need to update?
	var targetupdate, poleupdate, posupdate;
	targetupdate = false
	poleupdate = false
	posupdate = false
	
	if (tl.ik_target != null && tl.ik_target_pos != null)
		targetupdate = !array_equals(tl.ik_target_pos, tl.ik_target.world_pos)
	
	if (tl.ik_pole_target != null)
		if (tl.ik_pole_target_pos != null)
			poleupdate = !array_equals(tl.ik_pole_target_pos, tl.ik_pole_target.world_pos)
	
	if (tl.ik_world_pos_prev != null)
		posupdate = !array_equals(tl.ik_world_pos_prev, tl.world_pos)
	
	if (!targetupdate && !poleupdate && !posupdate && (tl.ik_angle_offset = tl.ik_angle_offset_prev))
		return 0
	
	tl.ik_angle_offset_prev = tl.ik_angle_offset
	
	// Offset pole target to ensure correct angle math
	haspole = (tl.ik_pole_target != null)
	
	if (haspole)
	{
		polepos = tl.ik_pole_target.world_pos
		tl.ik_pole_target_pos = polepos
		
		if (polepos[X] = tl.world_pos[X])
			polepos[X] += 0.0001
		
		if (polepos[Y] = tl.world_pos[Y])
			polepos[Y] += 0.0001
		
		if (polepos[Z] = tl.world_pos[Z])
			polepos[Z] += 0.0001
	}
	
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
		endpos = tl.ik_target.world_pos
		tl.ik_target_pos = endpos
		
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
		if (point3D_distance(jointpos[0], endpos) > (jointlength[0] + jointlength[1]))
		{
			var dir = vec3_direction(jointpos[0], endpos);
			
			for (i = 1; i < array_length(jointpos); i++)
				jointpos[i] = point3D_add(jointpos[i - 1], vec3_mul(dir, jointlength[i - 1]))
		}
		else // Calculate inverse kinematics (FABRIK)
		{
			// Offset target position on Y axis if aligned with joints
			var dir1, dir2;
			dir1 = vec3_direction(jointpos[0], endpos)
			dir2 = vec3_direction(jointpos[0], jointpos[1])
			
			if (abs(dir1[X]) = abs(dir2[X]) &&
				abs(dir1[Y]) = abs(dir2[Y]) &&
				abs(dir1[Z]) = abs(dir2[Z]))
					endpos = point3D_add(endpos, vec3_mul(vec3_normalize(vec3_cross(dir1, vec3(-1, 0, 0))), 0.0001))
			
			var dis = point3D_distance(jointpos[0], endpos);
			
			for (var t = 0; t < 30 && (dis > 0.01); t++)
			{
				// Backwards
				for (var i = array_length(jointpos) - 1; i > 0; i--)
				{
					// Set last joint at target
					if (i = array_length(jointpos) - 1)
						jointpos[i] = endpos
					else // Get angle between between previous point and the current point's last position and adjust
						jointpos[i] = point3D_add(jointpos[i + 1], vec3_mul(vec3_direction(jointpos[i + 1], jointpos[i]), jointlength[i]))
				}
				
				// Forwards
				for (var i = 1; i < array_length(jointpos); i++)
					jointpos[i] = point3D_add(jointpos[i - 1], vec3_mul(vec3_direction(jointpos[i - 1], jointpos[i]), jointlength[i - 1]))
				
				// Update distance
				dis = point3D_distance(jointpos[0], endpos)
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
	if (haspole && !nobend)
	{
		var poleproj, angle;
		poleproj = point3D_project_plane(polepos, p0, ac)
		p1proj = point3D_project_plane(p1, p0, ac)
		angle = point3D_angle_signed(point3D_sub(p1proj, p0), point3D_sub(poleproj, p0), ac)
		
		p1 = point3D_add(p0, vec3_rotate_axis_angle(point3D_sub(p1, p0), ac, degtorad(angle + tl.ik_angle_offset)))
		
		// Update directions
		ab = vec3_direction(p0, p1)
		bc = vec3_direction(p1, p2)
	}
	
	// Get front-facing direction
	if (!haspole && nobend)
	{
		// No pole target and straight, use arbitrary direction
		if (ab[X] = 0 && ab[Y] = 0)
			n = vec3_normal(ab, -90)
		else
			n = vec3_normal(ab, 0)
	}
	else
	{
		if (haspole && nobend) // Uses pole target & no bending present
			p2proj = point3D_project_plane(polepos, p0, ab)
		else
			p2proj = point3D_project_plane(p2, p0, ab)
		
		n = vec3_direction(p2proj, p0)
		
		// Apply angle offset to no-bend
		if (haspole && nobend)
			n = vec3_rotate_axis_angle(n, ac, degtorad(tl.ik_angle_offset))
		
		// Flip direction based on invert
		if (tl.model_part.bend_invert[X])
			n = vec3_mul(n, -1)
		
		if (haspole && nobend)
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