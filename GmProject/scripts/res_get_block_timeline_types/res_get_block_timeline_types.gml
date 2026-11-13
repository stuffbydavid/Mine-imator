/// @desc Returns the available timeline types, or null to skip filtering when all are enabled.

function res_get_block_timeline_types()
{
	if (scenery_tl_all_types)
		return null

	var types;
	types = []

	for (var i = 0; i < array_length(scenery_tl_types); i++)
	{
		var type, count;
		type = scenery_tl_types[i]
		count = value_get_real(scenery_tl_types_count_map[?type], 0)
		
		if (count > 0)
			array_add(types, type)
	}

	return types
}
