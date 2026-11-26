function action_build_structure(structure, custom = -1)
{
	if (structure != null && !instance_exists(structure))
		structure = null

	if (structure != null && !type_is_structure(structure.type))
		return 0

	if (custom != -1)
		build_structure_custom = custom
	
	if (build_structure = structure && place_target_tl_root = structure)
		return 0

	if (place_target_tl_root != null && instance_exists(place_target_tl_root))
		with (place_target_tl_root)
			tl_mark_place_target(false)

	build_structure = structure
	place_target_tl_root = structure
	
	if (structure != null)
		with (structure)
			tl_mark_place_target(true)
}
