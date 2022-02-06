/// action_group_reset()

function action_group_reset()
{
	var def;
	
	switch (context_menu_group)
	{
		case e_context_group.ROT_POINT:
		{
			if (tl_edit.part_of = null && tl_edit.temp != null)
				def = tl_edit.temp.rot_point
			else
				def = point3D(0, 0, 0)
			
			action_tl_rotpoint_all(def)
			return;
		}
		
		case e_context_group.POSITION:
		{
			if (tl_edit.part_of = null)
				def = point3D(0, 0, 0)
			else
				def = point3D(tl_edit.value_default[e_value.POS_X], tl_edit.value_default[e_value.POS_Y], tl_edit.value_default[e_value.POS_Z])
			
			action_tl_frame_pos_xyz(def)
			return;
		}
		
		case e_context_group.ROTATION:
		{
			def = point3D(tl_edit.value_default[e_value.ROT_X], tl_edit.value_default[e_value.ROT_Y], tl_edit.value_default[e_value.ROT_Z])
			
			action_tl_frame_rot_xyz(def)
			return;
		}
		
		case e_context_group.SCALE:
		{
			action_tl_frame_scale_xyz(vec3(1))
			return;
		}
		
		case e_context_group.BEND:
		{
			action_tl_frame_bend_angle_xyz(tl_edit.model_part.bend_default_angle)
			return;
		}
		
		case e_context_group.LIGHT:
		{
			action_tl_frame_set_light(c_white, 1, 1, 2, 250, 0.5, 50, 0.5)
			return;
		}
		
		case e_context_group.COLOR:
		{
			action_tl_frame_set_colors(1, c_black, c_black, c_white, c_black, c_black, c_white, c_black, c_black, 0, 0)
			return;
		}
		
		case e_context_group.CAMERA:
		{
			action_tl_frame_set_camera(camera_use_default_list, true)
			return;
		}
		
		case e_context_group.EASE:
		{
			action_tl_frame_ease_set_all([1, 0, 0, 1], false)
			return;
		}
	}
}
