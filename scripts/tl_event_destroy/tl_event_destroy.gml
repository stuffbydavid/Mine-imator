/// tl_event_destroy()
/// @desc Destroy event of timelines

function tl_event_destroy()
{
	if (!delete_ready)
		tl_remove_clean()
}
