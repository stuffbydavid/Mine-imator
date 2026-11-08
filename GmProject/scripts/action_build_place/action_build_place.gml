/// @arg [airblock]

function action_build_place(airblock = false)
{
	var hobj, target, blockpos, blockdata, blocktl, created, block, changes;
	hobj = null
	target = null
	created = false
	block = null
	changes = null

	// Restore the target and edits by the original action
	if (history_undo || history_redo)
	{
		hobj = history_data
		target = save_id_find(hobj.target_save_id)
		if (target = null && !(history_redo && hobj.mesh_save_obj != null))
			return false

		blockpos = hobj.block_pos
		changes = hobj.new_blocks
	}
	else
	{
		if (!airblock && (!place_build || place_pos = null))
			return false

		// Find target on cursor
		if (place_target_tl != null && instance_exists(place_target_tl))
			target = place_target_tl

		blockdata = [ 0, 0 ]
		if (airblock)
		{
			// Removal replaces the hit block with air
			if (target = null || !type_is_structure(target.type) || place_block_pos = null)
				return false

			blockpos = array_copy_1d(place_block_pos)
		}
		else
		{
			// Resolve the selected block or special model to block data
			if (build_type = e_tl_type.BLOCK)
			{
				block = mc_assets.block_name_map[?build_settings.block_name]
				if (is_undefined(block) || block = null)
					return false
				
				blockdata = [ block.block_id, block_get_state_id(block, build_settings.block_state) ]
			}
			else
				blockdata = block_get_from_timeline(build_settings.model_name, build_settings.model_state)

			// Interactions take precedence over placement, independently of the selected block
			var used = action_build_use(blockdata, keyboard_check(vk_shift));
			if (used != null)
				return used

			// Models without block data always use timeline placement
			if (blockdata = null)
				return action_build_place_timeline()

			// Respect an explicitly selected destination structure
			if (target != null && type_is_structure(target.type) && build_structure_custom && target != build_structure)
			{
				var par = target.parent;
				while (par != null && par != app && par != build_structure)
					par = par.parent
				
				if (par != build_structure)
					target = null
			}
			
			if (target = null || !type_is_structure(target.type))
			{
				target = build_structure
				
				if (target != null && !instance_exists(target))
					target = null
			}

			var transform, origin;
			if (target = null)
			{
				// Anchor a new structure so its first block occupies the origin cell
				var rotpoint = vec3(block_half_size, block_half_size, 0);
				if (build_type = e_tl_type.BLOCK)
					rotpoint = build_settings.rot_point
				
				transform = matrix_create(place_pos, place_rot, place_sca)
				origin = point3D_mul_matrix(vec3_mul(rotpoint, -1), transform)
				transform = matrix_create(origin, place_rot, place_sca)
				blockpos = vec3(0)
			}
			else
			{
				// Find the destination cell in the existing structure's local space
				transform = target.matrix_render
				
				with (target)
					if (!tl_scenery_load_blocks())
						return false

				if (target = place_target_tl && place_block_pos != null)
					blockpos = vec3_add(place_block_pos, place_view_normal)
				else
				{
					var localpos = point3D_mul_matrix(place_pos, matrix_inverse_ext(transform));
					blockpos = vec3(floor(localpos[X] / block_size), floor(localpos[Y] / block_size), floor(localpos[Z] / block_size))
				}
			}

			// Resolve placement state and any connected block changes
			block = block_objs[blockdata[0]]
			changes = block_build_place(block, blockdata[1], target, blockpos, transform)
			if (changes = null)
				return false

			// Use the resolved block when choosing mesh or timeline placement
			blockpos = changes[0][0]
			blockdata = [ changes[0][1], changes[0][2] ]
			block = block_objs[blockdata[0]]
			blocktl = (block.timeline && array_contains(scenery_timeline_enabled, block.tl_type))
			
			// Ctrl swaps the default unless the block requires a timeline
			if (keyboard_check(vk_control))
				blocktl = !blocktl
			
			if (block.timeline && ds_map_exists(mc_assets.block_tl_required_map, block.tl_type))
				blocktl = true

			if (blocktl)
				return action_build_place_timeline(blockdata, target, blockpos, transform)

			// Block mesh editing unavailable in GameMaker
			if (!is_cpp())
				return false
			
			if (target = null)
			{
				// Create the structure before applying its first mesh edit
				target = tl_new_structure(origin)
				with (target)
					tl_value_set_matrix(id, transform)
				
				created = true
				
				tl_update_list()
				tl_update_matrix()
				
				action_build_structure(target)
			}
		}
	}

	var prevblocks;
	if (history_undo && hobj.mesh_save_obj != null)
	{
		// Undo the whole structure when this action created it
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
		// Restore the structure and its saved mesh edits together
		target = history_restore_tl(hobj.mesh_save_obj)
		if (target.parent = app)
			action_build_structure(target, false)
	}
	else
	{
		// Apply the new edit or redo the block states
		with (target)
		{
			if (history_undo)
				prevblocks = tl_update_block_meshes(blockpos, 0, 0, hobj.old_blocks)
			else if (history_redo)
				prevblocks = tl_update_block_meshes(blockpos, 0, 0, changes)
			else
				prevblocks = tl_update_block_meshes(blockpos, blockdata[0], blockdata[1], changes, !airblock)
		}

		if (prevblocks = null)
			return false
	}

	// Record both states for every affected block
	if (hobj = null)
	{
		hobj = history_set(action_build_place)
		hobj.target_save_id = target.save_id
		hobj.block_pos = blockpos
		hobj.old_blocks = prevblocks
		hobj.new_blocks = []
		
		// Capture resolved states after neighboring block updates
		for (var i = 0; i < array_length(prevblocks); i++)
		{
			var pos, data;
			pos = prevblocks[i][0]
			data = [ 0, 0, false ]
			with (target)
				data = block_meshes_get_block(pos[X], pos[Y], pos[Z])
			
			array_add(hobj.new_blocks, [ array_copy_1d(pos), data[0], data[1], data[2] ], false)
		}
		
		hobj.mesh_save_obj = null

		// Save newly created structures
		if (created)
			with (hobj)
				mesh_save_obj = history_save_tl(target)

		// Focus on the placed or removed block in world space
		camera_work_set_focus(point3D_mul_matrix(vec3_mul(vec3_add(blockpos, 0.5), block_size), target.matrix_render))
	}

	if (hobj.mesh_save_obj != null)
	{
		tl_update_list()
		tl_update_matrix()
		project_update_counts()
	}

	// Clear the placement preview until the next hit update
	place_pos = null
	place_view_pos = null
	build_box_render = null
	place_block_pos = null

	render_world_changed()

	return true
}
