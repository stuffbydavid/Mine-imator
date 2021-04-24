/// action_res_list(resource)
/// @arg resource

function action_res_list(res)
{
	action_tl_play_break()
	res_edit = res
	properties.resources.preview.select = res
	properties.resources.preview.update = true
}
