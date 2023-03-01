/// action_tl_move_start()
/// @desc Move selected into dummy object

function action_tl_move_start()
{
	window_busy = "timelinemove"
	
	timeline_move_obj = new_obj(obj_data)
	timeline_move_obj.tree_list = ds_list_create()
	timeline_move_obj.tree_list_filter = ds_list_create()
	
	action_tl_move_start_tree()
	tl_update_list()
}
