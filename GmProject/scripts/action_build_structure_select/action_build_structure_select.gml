function action_build_structure_select(structure)
{
	// Find the first structure in the timeline's parent hierarchy
	if (structure != null && instance_exists(structure))
	{
		while (structure != app && !type_is_structure(structure.type))
			structure = structure.parent

		if (structure = app)
			return 0
	}

	action_build_structure(structure, true)
	
	place_target_tl = null
	place_view_pos = null
}
