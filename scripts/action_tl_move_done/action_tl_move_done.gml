/// action_tl_move_done(parent, position)
/// @arg parent
/// @arg position

function action_tl_move_done(par, pos)
{
	if (par = null)
	{
		par = app
		pos = null
	}
	
	action_tl_parent(par, pos)
	
	with (timeline_move_obj)
	{
		ds_list_destroy(tree_list)
		instance_destroy()
	}
	timeline_move_obj = null
	
	window_busy = ""
}
