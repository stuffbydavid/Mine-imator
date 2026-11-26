/// @desc Mark a given view as changed, or update both.

function view_changed(view = null)
{
	if (view = null)
	{
		with (obj_view)
		{
			update = true
			update_gizmos = true
		}
	}
	else
	{
		view.update = true
		view.update_gizmos = true
	}
}
