/// @arg [airblock]

function action_build_place(airblock = false)
{
	var hobj, target, blockpos, blockdata, blocktl, created, block;
	hobj = null
	target = null
	created = false
	block = null

	if (history_undo || history_redo)
	{
		hobj = history_data
		target = save_id_find(hobj.target_save_id)
		if (target = null && !(history_redo && hobj.mesh_save_obj != null))
			return false

		blockpos = hobj.block_pos
		blockdata = [ hobj.block_id, hobj.state_id ]
	}
	else
	{
		if (!airblock && (!place_build || place_pos = null))
			return false

		// Select target
		if (place_target_tl != null && instance_exists(place_target_tl))
			target = place_target_tl

		blocktl = !airblock
		blockdata = [ 0, 0 ]

		if (!airblock)
		{
			var ctrl = keyboard_check(vk_control);
			if (build_type = e_tl_type.BLOCK)
			{
				block = mc_assets.block_name_map[?build_settings.block_name]
				if (is_undefined(block) || block = null)
					return false

				blockdata = [ block.block_id, block_get_state_id(block, build_settings.block_state) ]

				if (block.timeline)
					blocktl = !ctrl
				else
					blocktl = ctrl
			}
			else
			{
				blockdata = block_get_from_timeline(build_settings.model_name, build_settings.model_state)
				if (blockdata != null)
				{
					block = block_objs[blockdata[0]]
					blocktl = !ctrl
				}
			}

			// Blocks without a mesh representation always need a timeline
			if (block != null && block.timeline && ds_map_exists(mc_assets.block_tl_required_map, block.tl_type))
				blocktl = true
		}

		if (blocktl)
			return action_build_place_timeline()

		if (!is_cpp()) // No GameMaker support for vertex buffer edits
			return false

		if (airblock)
		{
			// Check for valid target
			if (target = null || !type_is_structure(target.type) || place_block_pos = null)
				return false

			blockpos = array_copy_1d(place_block_pos)
		}
		else
		{
			// Check for valid structure in hierarchy
			if (target != null && type_is_structure(target.type) && build_structure_custom && target != build_structure)
			{
				var par = target.parent;
				while (par != null && par != app && par != build_structure)
					par = par.parent

				if (par != build_structure)
					target = null
			}

			// Select target from build tool setting
			if (target = null || !type_is_structure(target.type))
			{
				target = build_structure
				if (target != null && !instance_exists(target))
					target = null
			}

			// Create new structure
			if (target = null)
			{
				var rotpoint, mat, origin;
				rotpoint = vec3(block_half_size, block_half_size, 0)
				if (build_type = e_tl_type.BLOCK)
					rotpoint = build_settings.rot_point

				mat = matrix_create(place_pos, place_rot, place_sca)
				origin = point3D_mul_matrix(vec3_mul(rotpoint, -1), mat)
				target = tl_new_structure(origin)
				with (target)
					tl_value_set_matrix(id, matrix_create(origin, app.place_rot, app.place_sca))

				created = true
				blockpos = vec3(0)

				tl_update_list()
				tl_update_matrix()

				action_build_structure(target)
			}

			// Adjust by existing face
			else if (target = place_target_tl && place_block_pos != null)
				blockpos = vec3_add(place_block_pos, place_view_normal)

			// Default to local origin
			else if (target.type = e_tl_type.STRUCTURE && array_length(target.blocks_added) = 0)
				blockpos = vec3(0)

			// Snap to grid
			else
			{
				var localpos = point3D_mul_matrix(place_pos, matrix_inverse_ext(target.matrix_render));
				blockpos = vec3(floor(localpos[X] / block_size), floor(localpos[Y] / block_size), floor(localpos[Z] / block_size))
			}
		}
	}

	var prevblocks;
	if (history_undo && hobj.mesh_save_obj != null)
	{
		if (build_structure = target)
			action_build_structure(null, false)

		with (target)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		place_target_tl = null
		if (place_target_tl_root != null && !instance_exists(place_target_tl_root))
			place_target_tl_root = null
	}
	else if (history_redo && hobj.mesh_save_obj != null)
	{
		target = history_restore_tl(hobj.mesh_save_obj)
		if (target.parent = app)
			action_build_structure(target, false)
	}
	else
	{
		with (target)
		{
			if (history_undo)
				prevblocks = tl_update_block_meshes(blockpos, 0, 0, hobj.previous_blocks)
			else
				prevblocks = tl_update_block_meshes(blockpos, blockdata[0], blockdata[1])
		}

		if (prevblocks = null)
			return false
	}

	// New action
	if (hobj = null)
	{
		hobj = history_set(action_build_place)
		hobj.target_save_id = target.save_id
		hobj.block_pos = blockpos
		hobj.previous_blocks = prevblocks
		hobj.block_id = blockdata[0]
		hobj.state_id = blockdata[1]
		hobj.mesh_save_obj = null

		if (created)
			with (hobj)
				mesh_save_obj = history_save_tl(target)

		// Focus on block
		var focuspos = blockpos;
		if (target = place_target_tl && place_block_pos != null)
			focuspos = place_block_pos

		cam_work_focus = point3D_mul_matrix(vec3_mul(vec3_add(focuspos, 0.5), block_size), target.matrix_render)
		cam_work_focus_tl = null
		tl_focus = null
	}

	if (hobj.mesh_save_obj != null)
	{
		tl_update_list()
		tl_update_matrix()
		project_update_counts()
	}

	place_pos = null
	place_view_pos = null
	build_box_render = null
	place_block_pos = null

	render_world_changed()

	return true
}
