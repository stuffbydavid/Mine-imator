/// action_group_paste()

function action_group_paste()
{
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
		case e_context_group.LIGHT: action_tl_frame_set_light(copy[0], copy[1], copy[2], copy[3], copy[4], copy[5], copy[6], copy[7]); return 0;
		case e_context_group.COLOR: action_tl_frame_set_colors(copy[0], copy[1], copy[2], copy[3], copy[4], copy[5], copy[6], copy[7], copy[8], copy[9]); return 0;
		case e_context_group.CAMERA: action_tl_frame_set_camera(copy); return 0;
		case e_context_group.EASE: action_tl_frame_ease_set_all(copy, false); return 0;
	}
}
