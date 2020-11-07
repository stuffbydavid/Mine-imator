/// action_group_copy()

var group = context_menu_group;

switch (group)
{
	case e_context_group.ROT_POINT:
	{
		context_group_copy_list[|group] = array_copy_1d(tl_edit.rot_point)
		return;
	}
	
	case e_context_group.POSITION:
	{
		context_group_copy_list[|group] = array(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z])
		return;
	}
	
	case e_context_group.ROTATION:
	{
		context_group_copy_list[|group] = array(tl_edit.value[e_value.ROT_X], tl_edit.value[e_value.ROT_Y], tl_edit.value[e_value.ROT_Z])
		return;
	}
	
	case e_context_group.SCALE:
	{
		context_group_copy_list[|group] = array(tl_edit.value[e_value.SCA_X], tl_edit.value[e_value.SCA_Y], tl_edit.value[e_value.SCA_Z])
		return;
	}
	
	case e_context_group.BEND:
	{
		context_group_copy_list[|group] = array(tl_edit.value[e_value.BEND_ANGLE_X], tl_edit.value[e_value.BEND_ANGLE_Y], tl_edit.value[e_value.BEND_ANGLE_Z])
		return;
	}
}
