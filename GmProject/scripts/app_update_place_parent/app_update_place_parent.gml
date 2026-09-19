/// app_update_place_parent()
/// Parent compatible objects that are being placed.

function app_update_place_parent()
{
	var newparent = null;
	
	if (place_target_tl != null)
	{
		// Block categories are parented to block and scenery objects
		if (place_tl.type = e_tl_type.BLOCK || place_tl.type = e_tl_type.SCENERY || place_tl.type = e_tl_type.SPECIAL_BLOCK)
		{
			if ((place_target_tl.type = e_tl_type.BLOCK || place_target_tl.type = e_tl_type.SCENERY) &&
				!(place_tl.type = e_tl_type.SCENERY && place_target_tl.type = e_tl_type.SCENERY)) // Don't parent scenery to each other
			{
				newparent = place_target_tl
			}
		}
		
		// Armor is parented to character models
		if (place_tl.type = e_tl_type.EQUIPMENT && place_tl.temp != null &&
			(place_target_tl_part_of.type = e_tl_type.CHARACTER || place_target_tl_part_of.type = e_tl_type.MODEL || place_target_tl_part_of.type = e_tl_type.SPECIAL_BLOCK))
		{
			newparent = place_target_tl_part_of
			place_parent_reset = true
			
			// Lock
			var model = mc_assets.model_name_map[?place_tl.temp.model_name];
			if (!is_undefined(model) && model.parent_lock)
				action_tl_lock_tree(place_tl, true, null)
		}
	}
	
	if (newparent != null)
		with (newparent)
			tl_mark_place_target(true)

	// Restore original parent/index
	var newparentindex = -1;
	if (newparent = null)
	{
		newparent = place_tl_parent
		newparentindex = place_tl_parent_index
	}
	
	// Parent to new or restore original parent
	if (place_tl.parent != newparent)
	{
		with (place_tl)
			tl_set_parent(newparent, newparentindex, !app.place_parent_reset)
		
		tl_update_list()
		tl_update_matrix()
	}
}
