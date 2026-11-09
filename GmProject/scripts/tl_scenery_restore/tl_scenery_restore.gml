/// @desc Restores source blocks and missing scenery parts while keeping existing animations.

function tl_scenery_restore()
{
	if (type != e_tl_type.SCENERY || temp = null || temp.scenery = null ||
		!temp.scenery.ready || !ds_list_valid(temp.scenery.scenery_tl_list))
		return false

	// Clear mesh overrides before removing added block timelines
	blocks_added = []
	blocks_added_palette = []

	// Collect added blocks without entering independent nested structures
	var root, tree, removed;
	root = id
	tree = [ root ]
	removed = []
	for (var t = 0; t < array_length(tree); t++)
	{
		with (tree[t])
		{
			if (t > 0 && type_is_structure(type))
				continue

			for (var c = 0; c < ds_list_size(tree_list); c++)
				array_add(tree, tree_list[|c])

			if ((type = e_tl_type.BLOCK || type = e_tl_type.SPECIAL_BLOCK) && part_of = null)
				array_add(removed, id)
		}
	}

	// Preserve unrelated children attached to added blocks or their model parts
	for (var t = 1; t < array_length(tree); t++)
	{
		with (tree[t])
		{
			if (array_contains(removed, id) || (part_of != null && part_of != root))
				continue

			var par = parent;
			while (par != app && par != root && !array_contains(removed, par))
				par = par.parent

			if (array_contains(removed, par))
				tl_set_parent(root, -1, true)
		}
	}

	// Remove additions together with their owned model parts and text
	for (var t = 0; t < array_length(removed); t++)
		with (removed[t])
			if (!delete_ready)
				tl_remove_clean()

	with (obj_timeline)
		if (delete_ready)
			instance_destroy()

	// Keep matching source parts and recreate missing parts using current block settings
	scenery_animate_create = true
	scenery_part_history = null
	
	tl_scenery_animate()
	tl_update_block_meshes()

	return true
}
