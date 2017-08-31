/// temp_update_model_timelines([historyobj])
/// @arg [historyobj]
/// @desc Update timelines of the changed model.

var hobj;
if (argument_count > 0)
	hobj = argument[0]
else
	hobj = null
	
with (obj_timeline)
{
	if (temp != other.id || part_of != null)
		continue
		
	// Missing model
	if (temp.model_file = null)
	{
		for (var p = 0; p < ds_list_size(part_list); p++)
			with (part_list[|p])
				model_part = null
				
		continue
	}
	
	// Save indices of children
	if (hobj != null)
	{
		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			with (part_list[|p])
			{
				for (var t = 0; t < ds_list_size(tree_list); t++)
				{
					with (tree_list[|t])
					{
						if (part_of != null)
							break
					
						with (hobj)
						{
							part_child_save_id[part_child_amount] = save_id_get(other.id)
							part_child_parent_save_id[part_child_amount] = save_id_get(other.parent)
							part_child_parent_tree_index[part_child_amount] = t
							part_child_amount++
						}
					}
				}
			}
		}
	}
	
	// Remove empty timelines and set others to root
	for (var p = 0; p < ds_list_size(part_list); p++)
	{
		with (part_list[|p])
		{
			// Check if unused
			if (ds_list_size(keyframe_list) = 0)
			{
				var unused = true;
				
				for (var mp = 0; mp < ds_list_size(temp.model_file.file_part_list); mp++)
				{
					if (temp.model_file.file_part_list[|mp].name = model_part_name)
					{
						unused = false
						break
					}
				}
				
				if (unused)
				{
					// Move children to root
					for (var t = 0; t < ds_list_size(tree_list); t++)
					{
						with (tree_list[|t])
						{
							if (part_of != null)
								break
							
							tl_set_parent(other.part_of)
							t--
						}
					}
					
					p--
					instance_destroy()
					continue
				}
			}
			
			model_part = null
			tl_set_parent(other.id)
			tl_update_value_types()
			tl_update_type_name()
			tl_update_display_name()
		}
	}
	
	// Construct new list of parts (re-use old timelines if possible)
	var newpartlist = ds_list_create();
	for (var mp = 0; mp < ds_list_size(temp.model_file.file_part_list); mp++)
	{
		// Check if there is a previous body part with the 
		// same name, and re-use that one if that's the case
		var part, tlexists;
		part = temp.model_file.file_part_list[|mp]
		tlexists = false
		
		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			if (part_list[|p].model_part_name = part.name)
			{
				ds_list_add(newpartlist, part_list[|p])
				tlexists = true
				break
			}	
		}
		
		// Otherwise create a timeline for it
		if (!tlexists)
			ds_list_add(newpartlist, tl_new_part(part))
	}
	
	ds_list_destroy(part_list)
	part_list = newpartlist
	tl_update_part_list(temp.model_file, id)
	tl_update_type_name()
	tl_update_display_name()
	update_matrix = true
}