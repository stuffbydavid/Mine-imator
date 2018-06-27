/// action_tl_lq_hiding_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

var tl, nval, hobj;
tl = argument0
nval = argument1
hobj = argument2

with (hobj)
	history_save_var(tl, tl.lq_hiding, nval)
			
tl.lq_hiding = nval

for (var i = 0; i < ds_list_size(tl.tree_list); i++)
	if (!tl.tree_list[|i].selected)
		action_tl_lq_hiding_tree(tl.tree_list[|i], nval, hobj)