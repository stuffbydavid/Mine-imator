/// @desc Resolves placement rules and returns the block edits in scenery coordinates.
/// @arg block
/// @arg stateid
/// @arg target
/// @arg position
/// @arg transform

function block_build_place(block, stateid, target, blockpos, transform)
{
	// Blocks without build data retain their selected state
	if (block.build_map = null)
		return [ [ blockpos, block.block_id, stateid ] ]

	// Convert the view direction to the structure's local builder axes
	var inverse, look, normal, face, viewdir, hit, shift;
	inverse = matrix_inverse_ext(transform)
	look = vec3_mul_matrix(place_view_direction, inverse)
	look = vec3(-look[Y], look[X], look[Z])
	
	// Use the clicked surface normal, or up when placing in empty space
	normal = vec3(0, 0, 1)
	if (!place_view_air)
	{
		normal = vec3_mul_matrix(place_view_world_normal, inverse)
		normal = vec3(-normal[Y], normal[X], normal[Z])
	}
	
	// Resolve the hit face and horizontal view direction
	face = vec3_get_dir(normal)
	viewdir = vec3_get_dir(look, [ "east", "west", "south", "north" ])
	
	// Keep the hit position as fractions within its block
	hit = point3D_mul_matrix(place_view_hit_pos, inverse)
	hit = vec3(-hit[Y] / block_size, hit[X] / block_size, hit[Z] / block_size)
	hit = vec3(hit[X] - floor(hit[X]), hit[Y] - floor(hit[Y]), hit[Z] - floor(hit[Z]))
	shift = keyboard_check(vk_shift)

	// Check allowed facing directions
	var allowed = value_get_array(block.build_map[?"hit_faces"], dir_names);
	if (!array_contains(allowed, dir_names[face]))
		return null

	// Map specific hit faces to blocks (sign, banner, mob head)
	var faces = block.build_map[?"face_blocks"];
	if (ds_map_valid(faces))
	{
		var key = "side";
		if (face = ZP)
			key = "up"
		else if (face = ZN)
			key = "down"

		var name = faces[?key];
		if (is_string(name))
		{
			// Preserve compatible selected states on the replacement block
			var vars = block_get_state_id_state_vars(block, stateid);
			block = mc_assets.block_name_map[?name]
			if (is_undefined(block))
				return null

			var newvars = array_copy_1d(block.default_state);
			state_vars_add(newvars, vars)
			stateid = block_get_state_id(block, newvars)
		}
	}

	// Apply a state before placement rules
	var preset = block.build_map[?"set"];
	if (is_string(preset))
	{
		var vars = block_get_state_id_state_vars(block, stateid);
		state_vars_add(vars, string_get_state_vars(preset))
		stateid = block_get_state_id(block, vars)
	}

	// Find facing state value
	var facing, source;
	facing = face // Default to hit face (hit_face)
	source = value_get_string(block.build_map[?"facing"], "")
	
	if (source != "")
	{
		// Get allowed directions
		var dirs = block.states_map[?"facing"].value_name;

		// view follows the looking direction
		if (source = "view")
			facing = vec3_get_dir(look, dirs)
		
		// view_clockwise turns the horizontal view direction by 90 degrees
		else if (source = "view_clockwise")
			facing = vec3_get_dir(vec3(-look[Y], look[X], 0), dirs)
		
		// view_inverted faces toward the viewer
		else if (source = "view_inverted")
			facing = vec3_get_dir(vec3_mul(look, -1), dirs)
		
		// hit_face_inverted points into the clicked surface
		else if (source = "hit_face_inverted")
			facing = face ^ 1

		// Floor and ceiling mounts use horizontal facing instead of up or down
		if (block.build_map[?"face"] = "hit_face" && face >= ZP)
			facing = viewdir
		
		else if (block.build_map[?"place"] = "ladder" && face >= ZP)
			facing = viewdir ^ 1
		
		// facing_fallback supplies a direction when the hit face is unsupported
		else if (!array_contains(dirs, dir_names[facing]))
		{
			var fallback = value_get_string(block.build_map[?"facing_fallback"], "");
			if (fallback = "")
				return null
			
			// view_inverted faces toward the viewer on unsupported faces
			if (fallback = "view_inverted")
				facing = vec3_get_dir(vec3_mul(look, -1), dirs)
			else
				for (var d = XP; d <= ZN; d++)
					if (dir_names[d] = fallback)
						facing = d
		}

		stateid = block_set_state_id_value(block, stateid, "facing", dir_names[facing])
	}

	// directions=hit_face_inverted enables the attachment toward the clicked block
	if (block.build_map[?"directions"] = "hit_face_inverted")
	{
		// Keep the existing directions unless the top face resets them
		var old = [ 0, 0 ];
		if (face != ZP)
			old = block_build_get_block(target, blockpos)

		for (var d = XP; d <= ZN; d++)
		{
			var value = "false";
			if (old[0] = block.block_id)
				value = block_get_state_id_value(block, old[1], dir_names[d])

			stateid = block_set_state_id_value(block, stateid, dir_names[d], value)
		}

		if (face != ZP)
			stateid = block_set_state_id_value(block, stateid, dir_names[face ^ 1], "true")
	}

	// axis=hit_face uses the surface axis
	// axis=view turns the horizontal viewing axis by 90 degrees clockwise
	if (block.build_map[?"axis"] = "hit_face" || block.build_map[?"axis"] = "view")
	{
		var axis = face div 2;
		if (block.build_map[?"axis"] = "view")
			axis = 1 - (viewdir div 2)
		
		// Convert builder axes to Minecraft axis names
		var axes = [ "x", "z", "y" ];
		stateid = block_set_state_id_value(block, stateid, "axis", axes[axis])
	}

	// half=hit selects top or bottom from the surface and hit height
	if (block.build_map[?"half"] = "hit")
	{
		var half = "bottom";
		if (face = ZN || (face < ZP && hit[Z] > 0.5))
			half = "top"
		
		// half_state changes the destination state name (default half)
		stateid = block_set_state_id_value(block, stateid, value_get_string(block.build_map[?"half_state"], "half"), half)
	}

	// face=hit_face selects floor, wall or ceiling mounting
	if (block.build_map[?"face"] = "hit_face")
	{
		var mounting = "wall";
		if (face = ZP)
			mounting = "floor"
		else if (face = ZN)
			mounting = "ceiling"
		
		stateid = block_set_state_id_value(block, stateid, "face", mounting)
	}

	// rotation=view quantizes the view angle into the 16 rotation states
	if (block.build_map[?"rotation"] = "view")
	{
		var rotation = round(radtodeg(arctan2(look[X], -look[Y])) / 22.5);
		
		// rotation_zero=north shifts the zero angle by half a turn
		if (block.build_map[?"rotation_zero"] = "north")
			rotation += 8
		
		stateid = block_set_state_id_value(block, stateid, "rotation", string((rotation mod 16 + 16) mod 16))
	}

	// place selects additional block-specific rules when provided
	var placement = value_get_string(block.build_map[?"place"], "");
	switch (placement)
	{
		case "slab":
		{
			// Merge only with a matching opposite mesh slab in the destination block
			var existing = [ 0, 0 ];
			if (target != null)
				with (target)
					existing = block_meshes_get_block(blockpos[X], blockpos[Y], blockpos[Z])

			if (existing[0] = block.block_id &&
				block_get_state_id_value(block, existing[1], "variant") = block_get_state_id_value(block, stateid, "variant") &&
				block_get_state_id_value(block, existing[1], "type") != "double" &&
				block_get_state_id_value(block, existing[1], "type") != block_get_state_id_value(block, stateid, "type"))
			{
				stateid = block_set_state_id_value(block, stateid, "type", "double")
			}
			
			break
		}

		case "door":
		{
			// Choose the hinge from the clicked side, adjacent blocks and hit position
			var forward, right, offset, leftblock, rightblock, hinge;
			forward = dir_get_vec3(facing)
			right = vec3(-forward[Y], forward[X], 0)
			offset = vec3(right[Y], -right[X], 0)
			leftblock = block_build_get_block(target, vec3_sub(blockpos, offset))
			rightblock = block_build_get_block(target, vec3_add(blockpos, offset))
			
			hinge = "left"
			if (face < ZP && vec3_dot(dir_get_vec3(face), right) != 0)
			{
				if (vec3_dot(dir_get_vec3(face), right) > 0)
					hinge = "right"
			}
			
			// Orient hinge away from air block
			else if (leftblock[0] = 0 && rightblock[0] != 0)
				hinge = "right"
			else if ((leftblock[0] = 0) = (rightblock[0] = 0) && vec3_dot(vec3_sub(hit, vec3(0.5)), right) > 0)
				hinge = "right"

			// Put the hinge opposite the neighboring door's position
			var neighbors = [ leftblock, rightblock ];
			for (var i = 0; i < array_length(neighbors); i++)
			{
				var neighbor = neighbors[i];
				if (neighbor[0] != block.block_id ||
					block_get_state_id_value(block, neighbor[1], "half") != "lower" ||
					block_get_state_id_value(block, neighbor[1], "facing") != dir_names[facing] ||
					block_get_state_id_value(block, neighbor[1], "variant") != block_get_state_id_value(block, stateid, "variant"))
					continue

				hinge = "left"
				if (i = 0)
					hinge = "right"
				
				break
			}

			stateid = block_set_state_id_value(block, stateid, "hinge", hinge)
			
			break
		}

		case "ladder":
		{
			// On floor or ceiling hits, look for a supporting wall behind the ladder
			if (face >= ZP)
			{
				facing = viewdir ^ 1

				// Continue the ladder below when placing on its top face
				if (face = ZP)
				{
					var below = block_build_get_block(target, vec3_sub(blockpos, vec3(0, 0, 1)));
					if (below[0] = block.block_id)
					{
						var belowfacing = block_get_state_id_value(block, below[1], "facing");
						for (var d = XP; d <= YN; d++)
						{
							if (dir_names[d] = belowfacing)
							{
								facing = d
								break
							}
						}
					}
				}

				if (!block_build_supported(target, blockpos, facing ^ 1))
					return null
				
				stateid = block_set_state_id_value(block, stateid, "facing", dir_names[facing])
			}
			
			break
		}

		case "fence_gate":
		{
			// Walls beside the gate set its lowered in_wall state
			var inwall = "false";
			
			// Check the two horizontal directions perpendicular to the facing axis
			for (var d = XP; d <= YN; d++)
			{
				if (d div 2 = facing div 2)
					continue
				
				var offset, neighbor;
				offset = dir_get_vec3(d)
				neighbor = block_build_get_block(target, vec3_add(blockpos, vec3(offset[Y], -offset[X], 0)))
				if (neighbor[0] != 0 && block_objs[neighbor[0]].type = "wall")
					inwall = "true"
			}
			
			stateid = block_set_state_id_value(block, stateid, "in_wall", inwall)
			
			break
		}

		case "hanging_sign":
		{
			// Shift selects attached chains instead of the default hanging arrangement
			stateid = block_set_state_id_value(block, stateid, "attached", shift ? "true" : "false")
			break
		}

		case "wall_hanging_sign":
		{
			// Keep the support bar along the clicked horizontal axis
			facing = XP
			if (face <= XN)
				facing = YP
			
			stateid = block_set_state_id_value(block, stateid, "facing", dir_names[facing])
			
			break
		}

		case "rail":
		{
			// Rails cannot stack on another rail
			var below = block_build_get_block(target, vec3_sub(blockpos, vec3(0, 0, 1)));
			if (below[0] != 0 && block_objs[below[0]].type = "rail")
				return null

			// Set the rail along the horizontal view axis before connection updates
			var shape = "north_south";
			if (viewdir <= XN)
				shape = "east_west"
			
			stateid = block_set_state_id_value(block, stateid, "shape", shape)
			
			break
		}

		case "attach":
		{
			// Add faces to the clicked block when it is the same attachable block type
			var old = block_build_get_block(target, blockpos);
			if (target = place_target_tl && place_block_pos != null)
			{
				var clicked = block_build_get_block(target, place_block_pos);
				if (clicked[0] = block.block_id)
				{
					// Vines extend downwards with the same wall faces
					if (block.type = "vine" && face = ZN)
					{
						stateid = block_set_state_id_value(block, clicked[1], "up", "false")
						break
					}

					blockpos = array_copy_1d(place_block_pos)
					old = clicked
				}
			}

			// Preserve existing faces, or clear all faces for a new block
			if (old[0] = block.block_id)
				stateid = old[1]
			else
				for (var d = XP; d <= ZN; d++)
					stateid = block_set_state_id_value(block, stateid, dir_names[d], "false")

			// Select the clicked face, falling back to a wall face for blocks without a floor face
			var attachdir = face ^ 1;
			if (is_undefined(block.states_map[?dir_names[attachdir]]))
				attachdir = viewdir

			stateid = block_set_state_id_value(block, stateid, dir_names[attachdir], "true")
			
			break
		}

		case "scaffolding":
		{
			// Show the bottom when the position directly below is empty
			var below = block_build_get_block(target, vec3_sub(blockpos, vec3(0, 0, 1)));
			stateid = block_set_state_id_value(block, stateid, "bottom", below[0] = 0 ? "true" : "false")
			break
		}

		case "bell":
		{
			// Choose floor, ceiling or wall attachment, checking for support on both sides
			var attachment = "floor";
			if (face = ZN)
				attachment = "ceiling"
			else if (face < ZP)
			{
				// Point the wall attachment toward the clicked support
				stateid = block_set_state_id_value(block, stateid, "facing", dir_names[face ^ 1])
				attachment = "single_wall"
				if (block_build_supported(target, blockpos, face))
					attachment = "double_wall"
			}
			
			stateid = block_set_state_id_value(block, stateid, "attachment", attachment)
			
			break
		}

		case "lantern":
		{
			// Standing lanterns use top-face hits and other placements need support above
			if (face != ZP && !block_build_supported(target, blockpos, ZP))
				return null
			
			stateid = block_set_state_id_value(block, stateid, "hanging", face = ZP ? "false" : "true")
			
			break
		}

		case "vertical":
		{
			// Side hits prefer upward growth when supported below, otherwise downward
			var vertical = face;
			if (face < ZP)
			{
				vertical = ZP
				if (!block_build_supported(target, blockpos, ZN))
					vertical = ZN
			}
			
			// Require support opposite the growth direction, allowing the same block
			if (!block_build_supported(target, blockpos, vertical ^ 1, block))
				return null
			
			stateid = block_set_state_id_value(block, stateid, "vertical_direction", dir_names[vertical])
			
			break
		}

		case "jigsaw":
		case "crafter":
		{
			// Jigsaws follow the hit face and crafters face against the viewing axis
			var orientation, frontdir, topdir;
			frontdir = vec3_get_dir(look) ^ 1
			topdir = viewdir
			if (placement = "jigsaw")
			{
				frontdir = face
				topdir = viewdir ^ 1
			}

			if (frontdir < ZP)
				orientation = dir_names[frontdir] + "_up"
			else
				orientation = dir_names[frontdir] + "_" + dir_names[topdir]
			
			stateid = block_set_state_id_value(block, stateid, "orientation", orientation)
			
			break
		}
	}

	// Expand the resolved state
	return block_build_get_connect(block, stateid, blockpos)
}
