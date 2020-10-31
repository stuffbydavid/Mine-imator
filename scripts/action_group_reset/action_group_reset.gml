/// action_group_reset()

switch (context_menu_group)
{
	case e_context_group.ROT_POINT:
	{
		var def;
		
		if (tl_edit.part_of = null && tl_edit.temp != null)
			def = tl_edit.temp.rot_point
		else
			def = point3D(0, 0, 0)
		
		action_tl_rotpoint_all(def)
		return 0;
	}
}
