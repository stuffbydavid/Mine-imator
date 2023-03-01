/// action_group_copy_global()

function action_group_copy_global()
{
	context_group_copy_list[|e_context_group.POSITION] = array_copy_1d(tl_edit.world_pos)
}
