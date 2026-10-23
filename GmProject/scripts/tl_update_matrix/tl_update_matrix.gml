/// @desc Updates matrixes and positions.
/// @arg [paths]
/// @arg [updateik]
/// @arg [updatepose]

/// CppGen reference<obj_timeline> matrixtimeline
/// CppGen reference<obj_timeline> matrixancestor
/// CppGen reference<obj_timeline> matrixancestorparent

function tl_update_matrix(usepaths = false, updateik = true, updatepose = false)
{
	var tlamount, viewupdate, worldupdate, start;
	tlamount = ds_list_size(app.project_timeline_list)
	viewupdate = false
	worldupdate = false

	
	if (object_index = obj_timeline)
		start = ds_list_find_index(app.project_timeline_list, id)
	else
		start = 0
	
	if (start = -1)
		return 0
	
	var profile = debug_profiler_begin("Timeline transforms");

	for (var i = start; i < tlamount; i++)
	{
		var matrixtimeline = app.project_timeline_list[|i];
		
		// Update children
		if (updateik && !updatepose && (matrixtimeline.type = e_tl_type.CHARACTER || matrixtimeline.type = e_tl_type.EQUIPMENT || matrixtimeline.type = e_tl_type.SPECIAL_BLOCK || matrixtimeline.type = e_tl_type.MODEL))
			for (var t = 0; t < ds_list_size(matrixtimeline.tree_list); t++)
				if (matrixtimeline.tree_list[|t].inherit_pose)
					array_add(app.project_inherit_pose_array, matrixtimeline.tree_list[|t])
		
		if (!matrixtimeline.update_matrix)
			continue
		
		// Delay timeline update if we inherit pose
		if (updateik && !updatepose && (array_length(app.project_inherit_pose_array) > 0) && array_contains(app.project_inherit_pose_array, matrixtimeline))
		{
			matrixtimeline.update_matrix = false
			continue
		}
		
		if (usepaths && (matrixtimeline.type = e_tl_type.PATH || matrixtimeline.type = e_tl_type.PATH_POINT))
		{
			matrixtimeline.update_matrix = false
			continue
		}
		
		with (matrixtimeline)
		{
			viewupdate = true
			
			if (type_is_visible(type) && type != e_tl_type.CAMERA && !type_is_light(type))
				worldupdate = true
			
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
				if (part_of != null)
					matrix_parent = matrix_multiply(matrix_create(model_part.position, model_part.rotation, vec3(1)), matrix_parent)
				else
					matrix_parent = matrix_multiply(matrix_create(point3D(0), model_part.rotation, vec3(1)), matrix_parent)
			}
			
			// Create main matrix
			var pos, rot, sca, hasik;
			pos = point3D(value[e_value.POS_X], value[e_value.POS_Y], value[e_value.POS_Z])
			rot = vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z])
			sca = vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z])
			
			matrix_local = matrix_create(pos, rot, sca)
			matrix = matrix_multiply(matrix_local, matrix_parent)
			
			hasik = (array_length(part_joints_matrix) > 0 && value[e_value.IK_TARGET] != null)
			
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
			var posebend = [ 0, 0, 0 ];
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
				var matrixancestor = id;
				while (true)
				{
					var matrixancestorparent = matrixancestor.parent;
					if (!matrixancestor.inherit_scale || matrixancestorparent = app)
						break
					
					sca = vec3_mul(sca, vec3(matrixancestorparent.value[e_value.SCA_X], matrixancestorparent.value[e_value.SCA_Y], matrixancestorparent.value[e_value.SCA_Z]))
					matrixancestor = matrixancestorparent
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
			
			if (type = e_tl_type.MODEL_PART)
				model_part_shape_render_matrix_part = null
			
			// Scale for position controls
			value_inherit[e_value.SCA_X] = 1
			value_inherit[e_value.SCA_Y] = 1
			value_inherit[e_value.SCA_Z] = 1
			
			var matrixancestor = id;
			while (1)
			{
				var matrixancestorparent = matrixancestor.parent;
				if (matrixancestorparent = app)
					break
			
				value_inherit[e_value.SCA_X] *= matrixancestorparent.value[e_value.SCA_X]
				value_inherit[e_value.SCA_Y] *= matrixancestorparent.value[e_value.SCA_Y]
				value_inherit[e_value.SCA_Z] *= matrixancestorparent.value[e_value.SCA_Z]
				
				if (!matrixancestorparent.inherit_scale)
					break
				
				matrixancestor = matrixancestorparent
			}
			
			// Inherit
			var lastalpha, lasttex, ikblend
			lastalpha = value_inherit[e_value.ALPHA];
			lasttex = value_inherit[e_value.TEXTURE_OBJ]
			ikblend = value[e_value.IK_BLEND] * hasik
			value_inherit[e_value.ALPHA] = value[e_value.ALPHA] // Multiplied
			value_inherit[e_value.RGB_ADD] = value[e_value.RGB_ADD] // Added
			value_inherit[e_value.RGB_SUB] = value[e_value.RGB_SUB] // Added
			value_inherit[e_value.RGB_MUL] = value[e_value.RGB_MUL] // Multiplied
			value_inherit[e_value.HSB_ADD] = value[e_value.HSB_ADD] // Added
			value_inherit[e_value.HSB_SUB] = value[e_value.HSB_SUB] // Added
			value_inherit[e_value.HSB_MUL] = value[e_value.HSB_MUL] // Multiplied
			value_inherit[e_value.MIX_COLOR] = value[e_value.MIX_COLOR] // Added
			value_inherit[e_value.GLOW_COLOR] = value[e_value.GLOW_COLOR] // Multiplied
			value_inherit[e_value.MIX_PERCENT] = value[e_value.MIX_PERCENT] // Added
			value_inherit[e_value.EMISSIVE] = value[e_value.EMISSIVE] // Added
			value_inherit[e_value.METALLIC] = value[e_value.METALLIC] // Added
			value_inherit[e_value.ROUGHNESS] = value[e_value.ROUGHNESS] // Added
			value_inherit[e_value.SUBSURFACE] = value[e_value.SUBSURFACE] // Added
			value_inherit[e_value.SUBSURFACE_RADIUS_RED] = value[e_value.SUBSURFACE_RADIUS_RED] // Multiplied
			value_inherit[e_value.SUBSURFACE_RADIUS_GREEN] = value[e_value.SUBSURFACE_RADIUS_GREEN] // Multiplied
			value_inherit[e_value.SUBSURFACE_RADIUS_BLUE] = value[e_value.SUBSURFACE_RADIUS_BLUE] // Multiplied
			value_inherit[e_value.SUBSURFACE_COLOR] = value[e_value.SUBSURFACE_COLOR] // Multiplied
			value_inherit[e_value.WIND_INFLUENCE] = value[e_value.WIND_INFLUENCE] // Multiplied
			value_inherit[e_value.VISIBLE] = value[e_value.VISIBLE]
			value_inherit[e_value.BEND_ANGLE_X] = value[e_value.BEND_ANGLE_X] * (1 - ikblend) // Added
			value_inherit[e_value.BEND_ANGLE_Y] = value[e_value.BEND_ANGLE_Y] * (1 - ikblend) // Added
			value_inherit[e_value.BEND_ANGLE_Z] = value[e_value.BEND_ANGLE_Z] * (1 - ikblend) // Added
			value_inherit[e_value.TEXTURE_OBJ] = value[e_value.TEXTURE_OBJ] // Overwritten
			value_inherit[e_value.TEXTURE_MATERIAL_OBJ] = value[e_value.TEXTURE_MATERIAL_OBJ] // Overwritten
			value_inherit[e_value.TEXTURE_NORMAL_OBJ] = value[e_value.TEXTURE_NORMAL_OBJ] // Overwritten
			
			var inhalpha, inhcolor, inhglowcolor, inhvis, inhbend, inhtex, inhsurf, inhsubsurf;
			inhalpha = true
			inhcolor = true
			inhglowcolor = true
			inhvis = true
			inhbend = true
			inhtex = true
			inhsurf = true
			inhsubsurf = true
			
			for (var j = X; j <= Z; j++)
				value_inherit[e_value.BEND_ANGLE_X + j] += posebend[j]
			
			matrixancestor = id
			while (true)
			{
				var matrixancestorparent = matrixancestor.parent;
				if (matrixancestorparent = app)
					break
				
				if (inhalpha && !matrixancestor.inherit_alpha)
					inhalpha = false
				
				if (inhcolor && !matrixancestor.inherit_color)
					inhcolor = false
				
				if (inhglowcolor && !matrixancestor.inherit_glow_color)
					inhglowcolor = false
				
				if (inhvis && !matrixancestor.inherit_visibility)
					inhvis = false
				
				if (inhbend && !matrixancestor.inherit_bend)
					inhbend = false
				
				if (inhtex && (!matrixancestor.inherit_texture || matrixancestor.value[e_value.TEXTURE_OBJ] > 0))
					inhtex = false
				
				if (inhsurf && (!matrixancestor.inherit_surface || matrixancestor.value[e_value.TEXTURE_MATERIAL_OBJ] > 0))
					inhsurf = false
				
				if (inhsubsurf && !matrixancestor.inherit_subsurface)
					inhsubsurf = false
				
				if (inhalpha)
					value_inherit[e_value.ALPHA] *= matrixancestorparent.value[e_value.ALPHA]
				
				if (inhcolor)
				{
					if (matrixancestorparent.value[e_value.RGB_ADD] != c_black)
						value_inherit[e_value.RGB_ADD] = color_add(value_inherit[e_value.RGB_ADD], matrixancestorparent.value[e_value.RGB_ADD])
					
					if (matrixancestorparent.value[e_value.RGB_SUB] != c_black)
						value_inherit[e_value.RGB_SUB] = color_add(value_inherit[e_value.RGB_SUB], matrixancestorparent.value[e_value.RGB_SUB])
					
					if (matrixancestorparent.value[e_value.RGB_MUL] != c_white)
						value_inherit[e_value.RGB_MUL] = color_multiply(value_inherit[e_value.RGB_MUL], matrixancestorparent.value[e_value.RGB_MUL])
					
					if (matrixancestorparent.value[e_value.HSB_ADD] != c_black)
						value_inherit[e_value.HSB_ADD] = color_add(value_inherit[e_value.HSB_ADD], matrixancestorparent.value[e_value.HSB_ADD])
					
					if (matrixancestorparent.value[e_value.HSB_SUB] != c_black)
						value_inherit[e_value.HSB_SUB] = color_add(value_inherit[e_value.HSB_SUB], matrixancestorparent.value[e_value.HSB_SUB])
					
					if (matrixancestorparent.value[e_value.HSB_MUL] != c_white)
						value_inherit[e_value.HSB_MUL] = color_multiply(value_inherit[e_value.HSB_MUL], matrixancestorparent.value[e_value.HSB_MUL])
					
					if (matrixancestorparent.value[e_value.MIX_COLOR] != c_black)
						value_inherit[e_value.MIX_COLOR] = color_add(value_inherit[e_value.MIX_COLOR], matrixancestorparent.value[e_value.MIX_COLOR])
					
					value_inherit[e_value.MIX_PERCENT] = clamp(value_inherit[e_value.MIX_PERCENT] + matrixancestorparent.value[e_value.MIX_PERCENT], 0, 1)
				}
				
				if (inhsurf)
				{
					value_inherit[e_value.TEXTURE_MATERIAL_OBJ] = matrixancestorparent.value[e_value.TEXTURE_MATERIAL_OBJ]
					value_inherit[e_value.TEXTURE_NORMAL_OBJ] = matrixancestorparent.value[e_value.TEXTURE_NORMAL_OBJ]
					value_inherit[e_value.METALLIC] = clamp(value_inherit[e_value.METALLIC] + matrixancestorparent.value[e_value.METALLIC], 0, 1)
					value_inherit[e_value.ROUGHNESS] = clamp(value_inherit[e_value.ROUGHNESS] * matrixancestorparent.value[e_value.ROUGHNESS], 0, 1)
					value_inherit[e_value.EMISSIVE] = (value_inherit[e_value.EMISSIVE] + matrixancestorparent.value[e_value.EMISSIVE])
				}
				
				if (inhsubsurf)
				{
					value_inherit[e_value.SUBSURFACE] = value_inherit[e_value.SUBSURFACE] + matrixancestorparent.value[e_value.SUBSURFACE]
					value_inherit[e_value.SUBSURFACE_RADIUS_RED] = clamp(value_inherit[e_value.SUBSURFACE_RADIUS_RED] * matrixancestorparent.value[e_value.SUBSURFACE_RADIUS_RED], 0, 1)
					value_inherit[e_value.SUBSURFACE_RADIUS_GREEN] = clamp(value_inherit[e_value.SUBSURFACE_RADIUS_GREEN] * matrixancestorparent.value[e_value.SUBSURFACE_RADIUS_GREEN], 0, 1)
					value_inherit[e_value.SUBSURFACE_RADIUS_BLUE] = clamp(value_inherit[e_value.SUBSURFACE_RADIUS_BLUE] * matrixancestorparent.value[e_value.SUBSURFACE_RADIUS_BLUE], 0, 1)
					
					if (matrixancestorparent.value[e_value.SUBSURFACE_COLOR] != c_white)
						value_inherit[e_value.SUBSURFACE_COLOR] = color_multiply(value_inherit[e_value.SUBSURFACE_COLOR], matrixancestorparent.value[e_value.SUBSURFACE_COLOR])
				}
				
				if (inhglowcolor && (matrixancestorparent.value[e_value.GLOW_COLOR] != c_white))
					value_inherit[e_value.GLOW_COLOR] = color_multiply(value_inherit[e_value.GLOW_COLOR], matrixancestorparent.value[e_value.GLOW_COLOR])
				
				if (inhvis)
					value_inherit[e_value.VISIBLE] *= matrixancestorparent.value[e_value.VISIBLE]
				
				if (inhbend)
				{
					value_inherit[e_value.BEND_ANGLE_X] += matrixancestorparent.value[e_value.BEND_ANGLE_X]
					value_inherit[e_value.BEND_ANGLE_Y] += matrixancestorparent.value[e_value.BEND_ANGLE_Y]
					value_inherit[e_value.BEND_ANGLE_Z] += matrixancestorparent.value[e_value.BEND_ANGLE_Z]
				}
				
				if (inhtex)
					value_inherit[e_value.TEXTURE_OBJ] = matrixancestorparent.value[e_value.TEXTURE_OBJ]
				
				value_inherit[e_value.WIND_INFLUENCE] *= matrixancestorparent.value[e_value.WIND_INFLUENCE]
				
				matrixancestor = matrixancestorparent
			}
			
			if (lastalpha != value_inherit[e_value.ALPHA])
				render_list_default_update = true
			
			colors_ext = (value_inherit[e_value.ALPHA] < 1 ||
						  value_inherit[e_value.RGB_ADD] - value_inherit[e_value.RGB_SUB] != c_black ||
						  value_inherit[e_value.HSB_ADD] - value_inherit[e_value.HSB_SUB] != c_black ||
						  value_inherit[e_value.HSB_MUL] < c_white ||
						  value_inherit[e_value.MIX_PERCENT] > 0 ||
						  part_mixing_shapes)
			
			// Add bend angle from IK
			if (hasik)
				value_inherit[e_value.BEND_ANGLE_X] += part_joint_bend_angle * ikblend
			
			if ((value_inherit[e_value.ALPHA] * 1000) != 0)
			{
				// Update 3D planes if texture changed
				if (lasttex != value_inherit[e_value.TEXTURE_OBJ] && model_part != null && model_part.has_3d_plane)
					tl_update_model_shape()
				else
				// Update bend if angle changed
					tl_update_model_shape_bend()
			}
			
			// Update objects following this path
			if (type = e_tl_type.PATH)
			{
				with (obj_timeline)
				{
					if (value[e_value.PATH_OBJ] = other.id)
						update_matrix = true
				}
			}
			
			// Update path
			if (type = e_tl_type.PATH_POINT && parent != app && parent.type = e_tl_type.PATH)
				parent.path_update = true
			
			if (update_matrix)
			{
				// Update children
				for (var t = 0; t < ds_list_size(tree_list); t++)
					tree_list[|t].update_matrix = true
			}
			
			// Update render resource
			if (lasttex != value_inherit[e_value.TEXTURE_OBJ] && tl_get_render_visible())
				tl_update_render_res()
			
			// Update shape matrices, vertex buffers and visibility
			if (type = e_tl_type.MODEL_PART && model_part != null)
				tl_update_model_shape_render()

			
			update_matrix = false
		}
	}
	
	// Update view buffers for accurate object placing
	if (worldupdate)
		render_world_changed()
	else if (viewupdate)
		view_changed()
	
	update_matrix = false
	
	// Inverse kinematics
	if (updateik)
	{
		if (app.project_ik_part_array = null)
		{
			app.project_ik_part_array = []
			with (obj_timeline)
				if (tl_supports_ik())
					array_add(app.project_ik_part_array, id)
		}
		
		tl_update_ik(app.project_ik_part_array)
	}

	// Update models with "inherit pose"
	if (updateik && !updatepose && array_length(app.project_inherit_pose_array) > 0)
	{
		for (var i = 0; i < array_length(app.project_inherit_pose_array); i++)
			app.project_inherit_pose_array[i].update_matrix = true
		
		with (app)
			tl_update_matrix(false, false, true)
		
		app.project_inherit_pose_array = []
	}
	debug_profiler_end("Timeline transforms", profile)
}
