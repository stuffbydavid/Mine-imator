/// recent_event_destroy()

function recent_event_destroy()
{
	ds_list_delete_value(app.recent_list, id)
}
