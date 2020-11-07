/// action_group_paste()

var group, copy;
group = context_menu_group;
copy = context_group_copy_list[|group]

switch (group)
{
	case e_context_group.ROT_POINT: action_tl_rotpoint_all(copy); return 0;
	case e_context_group.POSITION: action_tl_frame_pos_xyz(copy); return 0;
	case e_context_group.ROTATION: action_tl_frame_rot_xyz(copy); return 0;
	case e_context_group.SCALE: action_tl_frame_scale_xyz(copy); return 0;
	case e_context_group.BEND: action_tl_frame_bend_angle_xyz(copy); return 0;
}