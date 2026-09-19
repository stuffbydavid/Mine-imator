/// action_res_list(resource)
/// @arg resource

function action_res_list(res)
{
	action_tl_play_break()
	
	with (properties.resources.preview)
	{
		if (select != res)
			preview_sound_stop()
			
		select = res
		update = true
	}
	
	res_edit = res
}
