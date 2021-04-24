/// marker_event_destroy()

function marker_event_destroy()
{
	ds_list_delete_value(app.timeline_marker_list, id)
}
