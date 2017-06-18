/// action_tl_move_start()
/// @desc Move selected into dummy object

window_busy = "timelinemove"

timeline_move_obj = new(obj_dummy)
timeline_move_obj.tree_amount = 0

action_tl_move_start_tree()
tl_update_list()
