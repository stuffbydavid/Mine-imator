/// action_group_paste()

var group, copy;
group = context_menu_group;
copy = context_group_copy_list[|group]

switch (group)
{
	case e_context_group.ROT_POINT: action_tl_rotpoint_all(copy); return 0;
}
