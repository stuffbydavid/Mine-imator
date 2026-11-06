/// @desc Applies state-dependent transforms to the existing block model parts.
/// @arg block
/// @arg stateid

function tl_apply_block_parts(block, stateid)
{
	// Skip models without parts or state-dependent part transforms
	if (part_list = null || block.tl_parts = null)
		return 0

	// Find the transform rules for each existing model part
	for (var i = 0; i < ds_list_size(part_list); i++)
	{
		var part, transforms, key;
		part = part_list[|i]
		transforms = block.tl_parts[?part.model_part_name]
		if (!ds_map_valid(transforms))
			continue

		// Apply the first rule matching the resolved block state
		key = ds_map_find_first(transforms)
		while (!is_undefined(key))
		{
			if (state_vars_match_state_id(string_get_state_vars(key), block, stateid))
			{
				var transform, pos, rot;
				transform = transforms[?key]
				pos = value_get_point3D(transform[?"position"], vec3(0))
				rot = value_get_point3D(transform[?"rotation"], vec3(0))

				// Update current and default values only for explicitly defined properties
				with (part)
				{
					if (ds_list_valid(transform[?"position"]))
					{
						tl_value_set_vec3(e_value.POS_X, pos)
						tl_value_set_vec3(e_value.POS_X, pos, true)
					}
					if (ds_list_valid(transform[?"rotation"]))
					{
						tl_value_set_vec3(e_value.ROT_X, rot)
						tl_value_set_vec3(e_value.ROT_X, rot, true)
					}
					update_matrix = true
				}
				
				break
			}
			
			key = ds_map_find_next(transforms, key)
		}
	}
}
