/// action_tl_extend_children_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

var tl, nval, hobj;
tl = argument0
nval = argument1
hobj = argument2

with (hobj)
	history_save_var(tl, tl.tree_extend, nval)
			
tl.tree_extend = nval

for (var i = 0; i < ds_list_size(tl.tree_list); i++)
	action_tl_extend_children_tree(tl.tree_list[|i], nval, hobj)