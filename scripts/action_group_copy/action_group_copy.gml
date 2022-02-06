/// action_group_copy()

function action_group_copy()
{
	
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
		
		case e_context_group.LIGHT:
		{
			context_group_copy_list[|group] = array(tl_edit.value[e_value.LIGHT_COLOR], tl_edit.value[e_value.LIGHT_STRENGTH], tl_edit.value[e_value.LIGHT_SPECULAR_STRENGTH],
													tl_edit.value[e_value.LIGHT_SIZE], tl_edit.value[e_value.LIGHT_RANGE], tl_edit.value[e_value.LIGHT_FADE_SIZE],
													tl_edit.value[e_value.LIGHT_SPOT_RADIUS], tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS])
			return;
		}
		
		case e_context_group.COLOR:
		{
			context_group_copy_list[|group] = array(tl_edit.value[e_value.ALPHA], tl_edit.value[e_value.RGB_ADD], tl_edit.value[e_value.RGB_SUB], 
													tl_edit.value[e_value.RGB_MUL], tl_edit.value[e_value.HSB_ADD], tl_edit.value[e_value.HSB_SUB],
													tl_edit.value[e_value.HSB_MUL], tl_edit.value[e_value.GLOW_COLOR], tl_edit.value[e_value.MIX_COLOR],
													tl_edit.value[e_value.MIX_PERCENT], tl_edit.value[e_value.BRIGHTNESS])
			return;
		}
		
		case e_context_group.CAMERA:
		{
			var arr = array_create(ds_list_size(camera_values_list), null);
			
			for (var i = 0; i < ds_list_size(camera_values_list); i++)
			{
				var vid = camera_values_list[|i];
				arr[i] = tl_edit.value[vid]
			}
			
			context_group_copy_list[|group] = arr
			
			return;
		}
		
		case e_context_group.EASE:
		{
			context_group_copy_list[|group] = [tl_edit.value[e_value.EASE_IN_X], tl_edit.value[e_value.EASE_IN_Y], tl_edit.value[e_value.EASE_OUT_X], tl_edit.value[e_value.EASE_OUT_Y]]
			return;
		}
	}
}
