function action_group_copy()
{
	var arr, srctl;
	srctl = tl_edit
	
	if (camera_effect_type_edit != null)
	{
		with (obj_timeline)
		{
			if (selected && type = e_tl_type.CAMERA_EFFECT && camera_effect_type = camera_effect_type_edit)
			{
				srctl = id
				break
			}
		}
	}
	
	switch (context_menu_group)
	{
		case e_context_group.ROT_POINT:
			arr = array_copy_1d(tl_edit.rot_point)
			break
		
		case e_context_group.POSITION:
			arr = [ tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z] ]
			break
		
		case e_context_group.ROTATION:
			arr = [ tl_edit.value[e_value.ROT_X], tl_edit.value[e_value.ROT_Y], tl_edit.value[e_value.ROT_Z] ]
			break
		
		case e_context_group.SCALE:
			arr = [ tl_edit.value[e_value.SCA_X], tl_edit.value[e_value.SCA_Y], tl_edit.value[e_value.SCA_Z] ]
			break
		
		case e_context_group.BEND:
			arr = [ tl_edit.value[e_value.BEND_ANGLE_X], tl_edit.value[e_value.BEND_ANGLE_Y], tl_edit.value[e_value.BEND_ANGLE_Z] ]
			break
		
		case e_context_group.LIGHT:
			arr = [ tl_edit.value[e_value.LIGHT_COLOR], tl_edit.value[e_value.LIGHT_STRENGTH], tl_edit.value[e_value.LIGHT_SPECULAR_STRENGTH],
					tl_edit.value[e_value.LIGHT_SIZE], tl_edit.value[e_value.LIGHT_RANGE], tl_edit.value[e_value.LIGHT_FADE_SIZE],
					tl_edit.value[e_value.LIGHT_SPOT_RADIUS], tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS] ]
			break
		
		case e_context_group.COLOR:
			arr = [ srctl.value[e_value.ALPHA], srctl.value[e_value.RGB_ADD], srctl.value[e_value.RGB_SUB],
					srctl.value[e_value.RGB_MUL], srctl.value[e_value.HSB_ADD], srctl.value[e_value.HSB_SUB],
					srctl.value[e_value.HSB_MUL], srctl.value[e_value.GLOW_COLOR], srctl.value[e_value.MIX_COLOR],
					srctl.value[e_value.MIX_PERCENT] ]
			break
		
		case e_context_group.CAMERA:
		{
			arr = array_create(ds_list_size(camera_values_list), null)
			
			for (var i = 0; i < ds_list_size(camera_values_list); i++)
			{
				var vid = camera_values_list[|i];
				arr[i] = srctl.value[vid]
			}
			
			break
		}
		
		case e_context_group.EASE:
			arr = [ tl_edit.value[e_value.EASE_IN_X], tl_edit.value[e_value.EASE_IN_Y], tl_edit.value[e_value.EASE_OUT_X], tl_edit.value[e_value.EASE_OUT_Y] ]
			break
		
		default:
			return 0
	}
	
	context_group_copy_list[|context_menu_group] = arr
}
