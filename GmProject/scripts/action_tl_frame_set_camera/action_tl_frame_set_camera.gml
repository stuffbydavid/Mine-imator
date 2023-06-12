/// action_tl_frame_set_camera(valueslist, [reset])
/// @arg valueslist
/// @arg [reset]

function action_tl_frame_set_camera(valueslist, reset = false)
{
	tl_value_set_start(action_tl_frame_set_camera, false)
	
	for (var i = 0; i < ds_list_size(camera_values_list); i++)
	{
		var vid = camera_values_list[|i];
		
		if (reset)
		{
			if (valueslist[i] = null)
				tl_value_set(vid, null, false)
			
			if (valueslist[i])
				tl_value_set(vid, tl_value_default(vid), false)
		}
		else
			tl_value_set(vid, valueslist[i], false)
	}
	
	tl_value_set_done()
}
