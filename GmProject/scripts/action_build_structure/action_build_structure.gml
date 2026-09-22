/// action_build_structure(structure)
/// @arg structure

function action_build_structure(structure)
{
	if (structure != null && !instance_exists(structure))
		structure = null

	if (structure != null && !type_is_structure(structure.type))
		return 0

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
