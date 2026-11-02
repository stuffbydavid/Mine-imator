/// @desc Uses the clicked block, returning null when ordinary placement should continue.
/// @arg [selected]
/// @arg [placeonly]

function action_build_use(selected = null, placeonly = false)
{
	var hobj, target;
	hobj = null
	
	if (history_undo || history_redo)
	{
		hobj = history_data
		target = save_id_find(hobj.target_save_id)
		if (target = null)
			return false

		// Restore timeline state changes, including shared template users
		if (hobj.timeline)
		{
			if (hobj.old_temp != null)
			{
				var save, source;
				save = hobj.new_temp
				if (history_undo)
					save = hobj.old_temp
				source = target.temp

				// Remove the current copies before restoring their saved trees
				for (var t = 0; t < save.usage_tl_amount; t++)
					with (save_id_find(save.usage_tl_save_obj[t].save_id))
						tl_remove_clean()

				with (obj_timeline)
					if (delete_ready)
						instance_destroy()

				// Restore model state on the original template
				with (source)
				{
					if (type = e_temp_type.BLOCK)
					{
						block_name = save.block_name
						block_state = array_copy_1d(save.block_state)
						block_transform = save.block_transform
						temp_update_block()
					}
					else
					{
						model_state = array_copy_1d(save.model_state)
						temp_update_model()
						temp_update_model_shape()
					}
					
					temp_update_display_name()
				}

				for (var t = 0; t < save.usage_tl_amount; t++)
					history_restore_tl(save.usage_tl_save_obj[t])
				
				target = save_id_find(hobj.target_save_id)
			}
			else
			{
				with (target)
					tl_remove_clean()

				with (obj_timeline)
					if (delete_ready)
						instance_destroy()

				var save = hobj.new_timeline;
				if (history_undo)
					save = hobj.old_timeline

				target = history_restore_tl(save)
			}

			// Restore selection
			with (hobj)
				history_restore_tl_select()
		}
		
		// Undo/redo block mesh change
		else
		{
			var changes = hobj.new_blocks;
			if (history_undo)
				changes = hobj.old_blocks
			
			with (target)
				tl_update_block_meshes(hobj.block_pos, 0, 0, changes)
		}
	}
	else
	{
		// Find target
		target = place_target_tl
		if (target = null || !instance_exists(target))
			return null
			
		if (target.type = e_tl_type.MODEL_PART && target.part_of != null)
			target = target.part_of

		var data, blockpos, timeline;
		data = null
		blockpos = null
		timeline = !type_is_structure(target.type)
		
		if (!timeline)
		{
			if (place_block_pos = null)
				return null
			
			with (target)
				if (!tl_load_blocks())
					return false

			blockpos = array_copy_1d(place_block_pos)
			data = block_build_get_block(target, blockpos)
		}
		else
			with (target)
				data = tl_get_build_block()

		if (data = null || data[0] = 0)
			return null

		var block, stateid, interaction, result;
		block = block_objs[data[0]]
		interaction = block_build_use(block, data[1], target, blockpos, selected, placeonly)
		if (interaction = null)
			return null

		blockpos = interaction[0]
		stateid = interaction[1]
		result = interaction[2]

		// Consumed interactions must not fall through to placement
		if (result[0] = data[0] && result[1] = stateid)
			return true
		
		// Air block removes
		if (timeline && result[0] = 0)
			return action_build_remove()

		if (timeline)
		{
			hobj = history_set(action_build_use)
			hobj.old_temp = null
			
			with (hobj)
			{
				history_save_tl_select()

				if (target.has_temp)
					old_temp = history_save_temp(target.temp)
				else
					old_timeline = history_save_tl(target)
			}
			
			with (target)
			{
				block_build_name = block.name
				block_build_state = block_get_state_id_state_vars(block, stateid)
				tl_set_build_state(block, result[1])
			}
			
			with (hobj)
			{
				if (target.has_temp)
					new_temp = history_save_temp(target.temp)
				else
					new_timeline = history_save_tl(target)
			}
		}
		else
		{
			var changes, prev;
			changes = [ [ blockpos, 0, 0 ] ]
			if (result[0] != 0)
				changes = block_build_get_connect(block, result[1], blockpos)

			// Clear blocks no longer occupied by the new state
			var occupied = block_build_get_connect(block, stateid, blockpos);
			for (var i = 0; i < array_length(occupied); i++)
			{
				var found = false;
				for (var c = 0; c < array_length(changes); c++)
					if (vec3_equals(occupied[i][0], changes[c][0]))
						found = true
				
				if (!found)
					array_add(changes, [ occupied[i][0], 0, 0 ], false)
			}

			with (target)
				prev = tl_update_block_meshes(blockpos, 0, 0, changes)
			
			if (prev = null)
				return true

			hobj = history_set(action_build_use)
			hobj.block_pos = blockpos
			hobj.old_blocks = prev
			hobj.new_blocks = []
			
			for (var i = 0; i < array_length(prev); i++)
			{
				var pos, next;
				pos = prev[i][0]
				next = block_build_get_block(target, pos)
				array_add(hobj.new_blocks, [ array_copy_1d(pos), next[0], next[1] ], false)
			}
		}
		
		hobj.target_save_id = target.save_id
		hobj.timeline = timeline
	}

	if (hobj.timeline)
	{
		with (target)
		{
			tl_update_parent_is_selected()
			
			if (parent != app && type_is_structure(parent.type) && (parent.place_target || parent.parent_is_place_target))
				tl_mark_place_target(true)
		}
	}
	
	place_target_tl = null
	if (place_target_tl_root != null && !instance_exists(place_target_tl_root))
		place_target_tl_root = null
	
	place_pos = null
	place_view_pos = null
	place_block_pos = null
	
	build_box_render = null
	
	tl_update_list()
	tl_update_matrix()
	
	app_update_tl_edit()
	project_update_counts()
	
	view_changed()

	return true
}
