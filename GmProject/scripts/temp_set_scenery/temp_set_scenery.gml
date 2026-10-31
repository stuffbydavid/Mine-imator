/// @arg resource
/// @arg animate
/// @arg [historyobject]
/// @arg [clearparts]
/// @arg [parts]

function temp_set_scenery(res, animate, hobj = null, clearparts = true, parts = null)
{
	var partroot = null;
	if (parts != null)
	{
		if (array_length(parts) = 0)
			return 0

		partroot = parts[0].part_of
	}

	// Save and remove old timelines
	with (obj_timeline)
	{
		if (temp != other.id || part_list = null || !clearparts || (partroot != null && id != partroot))
			continue
		
		var root, oldparts;
		root = id
		oldparts = []
		
		// Go through parts
		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			var part = part_list[|p];
			if (parts != null && !array_contains(parts, part))
				continue

			array_add(oldparts, part)

			with (part_list[|p])
			{
				// Save non-part children
				if (hobj != null)
				{
					for (var t = 0; t < ds_list_size(tree_list); t++)
					{
						with (tree_list[|t])
						{
							if (part_of != null)
								continue
							
							with (hobj)
							{
								part_child_save_id[part_child_amount] = other.save_id
								part_child_parent_save_id[part_child_amount] = other.parent.save_id
								part_child_parent_tree_index[part_child_amount] = t
								part_child_amount++
							}
						}
					}
				}
				
				// Relocate non-part children
				for (var t = 0; t < ds_list_size(tree_list); t++)
				{
					with (tree_list[|t])
					{
						if (part_of = null)
						{
							tl_set_parent(root)
							t--
						}
					}
				}
				
				// Save and relocate non-part sub-children
				if (part_list != null)
				{
					for (var sp = 0; sp < ds_list_size(part_list); sp++)
					{
						with (part_list[|sp])
						{
							// Save
							if (hobj != null)
							{
								for (var t = 0; t < ds_list_size(tree_list); t++)
								{
									with (tree_list[|t])
									{
										if (part_of != null)
											continue
										
										with (hobj)
										{
											part_child_save_id[part_child_amount] = other.save_id
											part_child_parent_save_id[part_child_amount] = other.parent.save_id
											part_child_parent_tree_index[part_child_amount] = t
											part_child_amount++
										}
									}
								}
							}
							
							// Relocate
							for (var t = 0; t < ds_list_size(tree_list); t++)
							{
								with (tree_list[|t])
								{
									if (part_of = null)
									{
										tl_set_parent(root)
										t--
									}
								}
							}
						}
					}
				}
				
				with (hobj)
					part_save_obj[part_amount++] = history_save_tl(other.id)
			}
		}

		if (array_length(oldparts) = 0)
			continue
		
		// Destroy
		for (var p = 0; p < array_length(oldparts); p++)
			with (oldparts[p])
				tl_remove_clean()
		
		with (obj_timeline)
			if (delete_ready)
				instance_destroy()
		
	}

	if (parts != null)
		return 0
	
	scenery = res
	
	if (scenery != null)
	{
		if (animate || !clearparts)
		{
			// Reconcile timelines after loading
			with (obj_timeline)
			{
				if (temp != other.id)
					continue

				scenery_part_history = hobj
				scenery_animate_create = animate
				
				if (animate && temp.scenery.ready)
					tl_animate_scenery()
				else
					scenery_animate = true
			}
		}
		
		if (scenery.ready)
		{
			temp_update_display_name()
			temp_update_rot_point()

			with (obj_timeline)
				if (temp = other.id && type = e_tl_type.SCENERY && (array_length(blocks_added) > 0 || array_length(block_meshes_edit) > 0))
					tl_update_block_meshes()
			
			with (app)
			{
				tl_update_list()
				tl_update_matrix()
			}
		}
	}
}
