/// action_build_remove()

function action_build_remove()
{
	var hobj, target, remove, structure;

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
				return 0
		}
		else
		{
			target = place_target_tl
			if (target = null || !instance_exists(target))
				return 0

			// Scenery block removal
			if (target.type = e_tl_type.SCENERY)
			{
				toast_new(e_toast.INFO, "Deleting scenery blocks coming soon")
				return 0
			}

			// Use the special block owning the rendered model part
			if (target.type = e_tl_type.MODEL_PART && target.part_of != null)
				target = target.part_of

			// Only blocks
			if (target.type != e_tl_type.BLOCK && target.type != e_tl_type.SPECIAL_BLOCK)
				return 0

			// Check for user-added block children
			if (target.type = e_tl_type.BLOCK)
			{
				if (ds_list_size(target.keyframe_list) > 1 || ds_list_size(target.tree_list) > 0)
					return 0
			}

			// Check the complete special block tree
			if (target.type = e_tl_type.SPECIAL_BLOCK)
			{
				var children = [target];
				for (var t = 0; t < array_length(children); t++)
				{
					var child = children[t];
					if (ds_list_size(child.keyframe_list) > 1)
						return 0

					for (var c = 0; c < ds_list_size(child.tree_list); c++)
					{
						var part = child.tree_list[|c];
						if (part.type != e_tl_type.MODEL_PART || part.part_of != target)
							return 0
						array_add(children, part)
					}
				}
			}

			// Remove an empty structure together with its final block
			structure = target.parent
			remove = target
			if (structure != app && structure.type = e_tl_type.STRUCTURE && ds_list_size(structure.tree_list) = 1 && structure.tree_list[|0] = target)
				remove = structure

			hobj = history_set(action_build_remove)
			hobj.remove_save_id = remove.save_id
			hobj.remove_save_obj = history_save_tl(remove)
			hobj.build_structure_removed = remove = build_structure
		}

		// Clear references before destroying the target
		if (place_target_tl_part_of != null && instance_exists(place_target_tl_part_of))
			with (place_target_tl_part_of)
				tl_mark_place_target(false)
		place_target_tl = null
		place_target_tl_part_of = null

		if (remove = build_structure)
			action_build_structure(null, false)

		with (remove)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()
	}

	place_pos = null
	place_view_pos = null
	view_main.update_place_surfaces = true
	view_second.update_place_surfaces = true

	tl_update_list()
	tl_update_length()
	tl_update_matrix()
	app_update_tl_edit()
	project_update_counts()
}
