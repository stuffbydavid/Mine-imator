/// tl_event_destroy()
/// @desc Destroy event of timelines

function tl_event_destroy()
{
	if (obj_edit = id)
	{
		obj_edit = null
		with (app)
			tab_close(object_editor)
	}

	if (!delete_ready)
		tl_remove_clean()
}
