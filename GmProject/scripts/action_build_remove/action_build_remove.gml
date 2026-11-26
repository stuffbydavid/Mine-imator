function action_build_remove()
{
	var hobj, target, remove, structure, focuspos;
	focuspos = null

	if (history_undo)
	{
		hobj = history_data
		remove = history_restore_tl(hobj.remove_save_obj)
		
		if (hobj.build_structure_removed)
			action_build_structure(remove)
	}
	else
	{
		if (history_redo)
		{
			hobj = history_data
			remove = save_id_find(hobj.remove_save_id)
			if (remove = null)
				return false
		}
		else
		{
			target = place_target_tl
			if (target = null || !instance_exists(target))
				return false

			// Use the special block owning the rendered model part
			if (target.type = e_tl_type.MODEL_PART && target.part_of != null)
				target = target.part_of

			// Replace a block with air in an existing block mesh
			if (type_is_structure(target.type))
				return action_build_place(true)

			// Only blocks
			if (target.type != e_tl_type.BLOCK && target.type != e_tl_type.SPECIAL_BLOCK)
				return false

			// Check for user-added block children
			if (target.type = e_tl_type.BLOCK)
			{
				if (ds_list_size(target.keyframe_list) > 1 || ds_list_size(target.tree_list) > 0)
					return false
			}

			// Check the complete special block tree
			if (target.type = e_tl_type.SPECIAL_BLOCK)
			{
				var children = [ target ];
				for (var t = 0; t < array_length(children); t++)
				{
					var child = children[t];
					if (ds_list_size(child.keyframe_list) > 1)
						return false

					for (var c = 0; c < ds_list_size(child.tree_list); c++)
					{
						var part = child.tree_list[|c];
						if (part.part_of != target || (part.type != e_tl_type.MODEL_PART && part.type != e_tl_type.TEXT))
							return false
						
						array_add(children, part)
					}
				}
			}

			// Clear retained block data before checking whether the structure is empty
			var previous = null;
			with (target)
				previous = tl_update_block_build(true)

			// Remove an empty structure together with its final block
			structure = target.parent
			remove = target
			if (structure != app && structure.type = e_tl_type.STRUCTURE && array_length(structure.blocks_added) = 0 &&
				ds_list_size(structure.tree_list) = 1 && structure.tree_list[|0] = target)
				remove = structure

			hobj = history_set(action_build_remove)
			hobj.remove_save_id = remove.save_id
			hobj.remove_save_obj = history_save_tl(remove)
			hobj.build_structure_removed = (remove = build_structure)

			// Capture waterlogging before the retained cell was cleared
			if (is_array(previous) && array_length(previous) > 0)
			{
				var savedblock = hobj.remove_save_obj;
				if (remove != target)
					savedblock = savedblock.tree_save_obj[0]

				savedblock.block_build_waterlogged = previous[0][3]
			}

			// Retain the removed block's world position before deleting its timeline
			focuspos = matrix_position(target.matrix)
		}

		place_target_tl = null

		// Reset structure setting to Create new
		if (remove = build_structure)
			action_build_structure(null, false)

		with (remove)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()
		
		if (place_target_tl_root != null && !instance_exists(place_target_tl_root))
			place_target_tl_root = null
	}

	place_pos = null
	place_view_pos = null
	place_block_pos = null
	
	build_box_render = null
	
	view_changed()

	tl_update_list()
	tl_update_length()
	tl_update_matrix()
	
	app_update_tl_edit()
	
	project_update_counts()

	if (focuspos != null)
		camera_work_set_focus(focuspos)
	
	return true
}
