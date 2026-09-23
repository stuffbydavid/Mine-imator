/// action_build_structure(structure, [custom])
/// @arg structure
/// @arg [custom]

function action_build_structure(structure, custom = -1)
{
	if (structure != null && !instance_exists(structure))
		structure = null

	if (structure != null && !type_is_structure(structure.type))
		return 0

	if (custom != -1)
		build_structure_custom = custom
	
	if (build_structure = structure && place_target_tl_part_of = structure)
		return 0

	if (place_target_tl_part_of != null && instance_exists(place_target_tl_part_of))
		with (place_target_tl_part_of)
			tl_mark_place_target(false)

	build_structure = structure
	place_target_tl_part_of = structure
	
	if (structure != null)
		with (structure)
			tl_mark_place_target(true)
}
