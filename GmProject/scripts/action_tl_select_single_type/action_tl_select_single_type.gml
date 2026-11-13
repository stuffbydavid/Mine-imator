/// @desc Deselects all but the first timeline of a given type.

function action_tl_select_single_type(type)
{
	if (history_undo || history_redo)
		return action_tl_select_single(null)

	var tl = null;

	with (obj_timeline)
	{
		if (self.type = type)
		{
			tl = id
			break
		}
	}

	if (tl != null)
		return action_tl_select_single(tl)

	return false
}
