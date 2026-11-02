/// @desc Creates a block timeline from a resolved placement state.
/// @arg [blockdata]
/// @arg [target]
/// @arg [position]
/// @arg [transform]

function action_build_place_timeline(blockdata = null, target = null, blockpos = null, transform = null)
{
	var hobj, created, tl;
	hobj = null
	created = false
	
	if (history_undo || history_redo)
	{
		hobj = history_data
		
		if (history_undo)
		{
			// Remove placed timeline or structure created with it
			tl = save_id_find(hobj.remove_save_id)
			if (tl != null)
			{
				if (build_structure = tl)
					action_build_structure(null, false)
				
				with (tl)
					tl_remove_clean()
			}
			
			with (obj_timeline)
				if (delete_ready)
					instance_destroy()
		}
		else
		{
			// Restore the saved timeline tree and structure selection
			tl = history_restore_tl(hobj.spawn_save_obj)
			
			if (type_is_structure(tl.type))
				action_build_structure(tl, false)
		}

		// Restore mesh states separately when the destination structure already existed
		if (hobj.mesh_target_save_id != "")
		{
			target = save_id_find(hobj.mesh_target_save_id)
			blockpos = hobj.old_mesh_blocks[0][0]
			
			if (target != null)
			{
				with (target)
				{
					if (history_undo)
						tl_update_block_meshes(blockpos, 0, 0, hobj.old_mesh_blocks)
					else
						tl_update_block_meshes(blockpos, 0, 0, hobj.new_mesh_blocks)
				}
			}
		}
	}
	else
	{
		// Resolve the placement parent when no block destination was supplied
		if (target = null && blockdata = null)
		{
			var action = null;
			if (place_target_tl != null && instance_exists(place_target_tl))
				with (build_settings)
					action = tl_get_place_parent_action(app.place_target_tl)
			
			if (is_array(action) && array_length(action) > e_parent_action.TARGET)
				target = action[e_parent_action.TARGET]
			
			if (target = app || (build_structure_custom && target != build_structure))
				target = null
			
			if (target = null && build_structure != null && instance_exists(build_structure))
				target = build_structure
		}

		// Create a destination structure
		if (target = null)
		{
			var origin = place_pos;
			if (transform != null)
				origin = matrix_position(transform)
			
			target = tl_new_structure(origin)
			
			if (transform != null)
				with (target)
					tl_value_set_matrix(id, transform)
			
			created = true
			
			tl_update_list()
			tl_update_matrix()
		}

		// Copy the workbench settings before applying resolved block data
		hobj = history_set(action_build_place_timeline)
		hobj.mesh_target_save_id = ""
		hobj.build_save_obj = history_save_bench(build_settings)
		hobj.build_save_obj.hobj = hobj
		
		var source, tltype, block, placemat;
		source = hobj.build_save_obj
		tltype = build_type
		block = null
		placemat = matrix_create(place_pos, place_rot, place_sca)

		// Convert the resolved block state into timeline model settings
		if (blockdata != null)
		{
			block = block_objs[blockdata[0]]
			tltype = e_tl_type.BLOCK
			
			source.block_name = block.name
			source.block_state = block_get_state_id_state_vars(block, blockdata[1])
			source.block_repeat_enable = false
			source.block_transform = true
			
			// The bed model is anchored at its head
			if (block.type = "bed")
				state_vars_set_value(source.block_state, "part", "head")
			
			// Apply metadata-defined model states and placement transforms
			if (block.timeline)
			{
				source.block_state = block_get_timeline_render_state(block, blockdata[1])
				source.block_transform = block.tl_build_transform
				
				if (block.tl_model_name != "")
				{
					tltype = e_tl_type.SPECIAL_BLOCK
					source.model_name = block.tl_model_name
					source.model_state = block_get_timeline_model_state(block, blockdata[1])
				}
				
				placemat = matrix_multiply(block_get_timeline_matrix(block, blockdata[1], blockpos), transform)
			}
			else
			{
				var pos, offset;
				pos = block_get_timeline_position(block, blockdata[1])
				offset = vec3(pos[Y], block_size - pos[X], pos[Z])
				placemat = matrix_multiply(matrix_create(vec3_add(vec3_mul(blockpos, block_size), offset), vec3(0), vec3(1)), transform)
			}

			// Keep the block mesh alongside an additional timeline model
			if (block.timeline && block.tl_model_double)
			{
				var prev = null;
				with (target)
					prev = tl_update_block_meshes(blockpos, blockdata[0], blockdata[1], null, true)

				// Save mesh changes separately unless the whole structure will be saved
				if (prev != null && !created)
				{
					hobj.mesh_target_save_id = target.save_id
					hobj.old_mesh_blocks = prev
					hobj.new_mesh_blocks = []
					
					// Capture resolved states for every affected mesh block
					for (var i = 0; i < array_length(prev); i++)
					{
						var pos, data;
						pos = prev[i][0];
						data = [ 0, 0 ];
						with (target)
							data = block_meshes_get_block(pos[X], pos[Y], pos[Z])
						
						array_add(hobj.new_mesh_blocks, [ array_copy_1d(pos), data[0], data[1] ], false)
					}
				}
			}
		}

		// Create the timeline and attach it to the destination structure
		tl = tl_new_block(tltype, source, true)
		with (tl)
		{
			tl_set_parent(target)
			
			if (block != null)
			{
				// Retain the source block state for later build interactions
				block_build_name = block.name
				block_build_state = block_get_state_id_state_vars(block, blockdata[1])
				
				if (block.timeline)
				{
					// Apply the block's pivot and default animation settings
					rot_point_custom = true
					rot_point = block_get_timeline_rot_point(block, blockdata[1])
					animated = block.tl_animated
					
					tl_update_rot_point()
					
					if (type = e_tl_type.SPECIAL_BLOCK)
					{
						// Enable animation for given parts only
						for (var p = 0; p < ds_list_size(part_list); p++)
							part_list[|p].animated = array_contains(block.tl_animated_parts, part_list[|p].model_part_name)
						
						tl_apply_block_parts(block, blockdata[1])
					}
				}
			}
			
			tl_value_set_matrix(id, placemat)
			update_matrix = true
		}

		// Select the destination structure and focus on the placed object
		action_build_structure(target, false)
		
		tl_focus = tl
		cam_work_focus = matrix_position(placemat)
		cam_work_focus_tl = null

		// Save the whole structure when placement created it
		var save = tl;
		if (created)
			save = target
		
		hobj.remove_save_id = save.save_id
		with (hobj)
			spawn_save_obj = history_save_tl(save)
	}

	// Inherit placement highlighting after creation or redo
	if (!history_undo)
	{
		with (tl)
		{
			tl_update_parent_is_selected()
			
			if (parent != app && type_is_structure(parent.type) && (parent.place_target || parent.parent_is_place_target))
				tl_mark_place_target(true)
		}
	}
	
	// Clear placement targets removed by undo or mesh updates
	if (place_target_tl != null && !instance_exists(place_target_tl))
		place_target_tl = null
	
	if (place_target_tl_root != null && !instance_exists(place_target_tl_root))
		place_target_tl_root = null

	tl_update_list()
	tl_update_matrix()
	
	app_update_tl_edit()
	project_update_counts()
	
	lib_preview.update = true
	
	place_pos = null
	place_view_pos = null
	place_block_pos = null
	
	build_box_render = null
	
	view_changed()

	return true
}
