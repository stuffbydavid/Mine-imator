/// app_update_place_parent()
/// Parent compatible objects that are being placed.

function app_update_place_parent()
{
	var newparent, newparentindex;
	newparent = place_tl_parent
	newparentindex = place_tl_parent_index
		
	if (place_target_tl != null)
	{
		// Block categories are parented to block and scenery objects
		if (place_tl.type = e_tl_type.BLOCK || place_tl.type = e_tl_type.SCENERY || place_tl.type = e_tl_type.SPECIAL_BLOCK)
		{
			if ((place_target_tl.type = e_tl_type.BLOCK || place_target_tl.type = e_tl_type.SCENERY) &&
				!(place_tl.type = e_tl_type.SCENERY && place_target_tl.type = e_tl_type.SCENERY)) // Don't parent scenery to each other
			{
				newparent = place_target_tl
				newparentindex = -1
			}
		}
	}
	
	// Parent to new or restore original parent
	if (place_tl.parent != newparent)
	{
		with (place_tl)
			tl_set_parent(newparent, newparentindex, true)
		
		tl_update_list()
		tl_update_matrix()
	}
}