/// keyframe_event_destroy()

function keyframe_event_destroy()
{
	ds_list_delete_value(timeline.keyframe_list, id)
	
}
