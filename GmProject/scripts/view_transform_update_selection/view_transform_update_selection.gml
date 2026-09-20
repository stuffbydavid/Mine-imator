/// view_transform_update_selection()
/// @desc Caches selected transform timelines and keyframe positions for each tool.

function view_transform_update_selection()
{
	view_control_transform_selection = []
	view_control_transform_key_marker = array_create(3, noone)
	view_control_transform_key_mixed = array_create(3, false)

	with (obj_timeline)
	{
		if (selected && (value_type[e_value_type.TRANSFORM_POS] ||
			value_type[e_value_type.TRANSFORM_ROT] || value_type[e_value_type.TRANSFORM_SCA]))
			other.view_control_transform_selection[array_length(other.view_control_transform_selection)] = id
	}

	// Keep each tool's markers separate: a scale-only key must not constrain Move.
	with (obj_keyframe)
	{
		if (!selected || !timeline.selected)
			continue

		for (var transform_type = e_value_type.TRANSFORM_POS; transform_type <= e_value_type.TRANSFORM_SCA; transform_type++)
		{
			if (!timeline.value_type[transform_type])
				continue

			var index = transform_type - e_value_type.TRANSFORM_POS;
			if (other.view_control_transform_key_marker[index] = noone)
				other.view_control_transform_key_marker[index] = position
			else if (other.view_control_transform_key_marker[index] != position)
				other.view_control_transform_key_mixed[index] = true
		}
	}
}
