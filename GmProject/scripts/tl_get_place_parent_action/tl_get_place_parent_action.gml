/// tl_get_place_parent_action(target)
/// @arg target

function tl_get_place_parent_action(target)
{
	if (!type_is_block(type))
		return tl_get_parent_action(target)

	var block = target;
	if (block.type = e_tl_type.MODEL_PART && block.part_of != null && type_is_block(block.part_of.type))
		block = block.part_of
	
	if (!type_is_block(block.type))
		return tl_get_parent_action(target)

	// A directly hit scenery is itself a valid parent
	if (block.type = e_tl_type.SCENERY)
		return array(block)

	// Use the nearest structure or scenery above the hit block
	var parent = block.parent;
	while (parent != null && parent != app)
	{
		if (type_is_structure(parent.type))
			return array(parent)
		
		parent = parent.parent
	}

	return array(app)
}
