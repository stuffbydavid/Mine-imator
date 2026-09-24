/// view_transform_selected_ancestor(timeline, transform_type)
/// @arg timeline
/// @arg transform_type
/// @desc Checks whether a selected ancestor already owns the transform.

function view_transform_selected_ancestor(timeline, transform_type)
{
	var child = timeline
	while (child.parent != app)
	{
		if (transform_type = e_value_type.TRANSFORM_POS ? !child.inherit_position : !child.inherit_scale)
			return false

		child = child.parent
		if (child.selected && child.value_type[transform_type])
			return true
	}

	return false
}
