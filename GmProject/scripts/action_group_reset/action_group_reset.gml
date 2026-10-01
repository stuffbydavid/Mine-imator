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
				def = point3D(0)
			
			action_tl_rotpoint_all(def)
			break
		}
		
		case e_context_group.POSITION:
		{
			def = point3D(tl_edit.value_default[e_value.POS_X], tl_edit.value_default[e_value.POS_Y], tl_edit.value_default[e_value.POS_Z])
			
			action_tl_frame_pos_xyz(def)
			break
		}
		
		case e_context_group.ROTATION:
		{
			if (tl_edit.type = e_tl_type.CAMERA)
				def = vec3(0)
			else
				def = vec3(tl_edit.value_default[e_value.ROT_X], tl_edit.value_default[e_value.ROT_Y], tl_edit.value_default[e_value.ROT_Z])
			
			action_tl_frame_rot_xyz(def)
			break
		}
		
		case e_context_group.SCALE:
			action_tl_frame_scale_xyz(vec3(1))
			break
		
		case e_context_group.BEND:
			action_tl_frame_bend_angle_xyz(tl_edit.model_part.bend_default_angle)
			break
		
		case e_context_group.LIGHT:
			action_tl_frame_set_light(c_white, 1, 1, 2, 250, 0.5, 50, 0.5)
			break
		
		case e_context_group.COLOR:
			action_tl_frame_set_colors(1, c_black, c_black, c_white, c_black, c_black, c_white, c_white, c_black, 0)
			break
		
		case e_context_group.CAMERA:
		{
			if (context_menu_camera_effect_type_edit = null)
				action_tl_frame_set_camera(camera_use_default_list, true)
			else
			{
				var fxtype, fxrange;
				fxtype = context_menu_camera_effect_type_edit
				fxrange = camera_effect_value_range_list[|fxtype]
				camera_effect_type_edit = fxtype
				
				tl_value_set_start(action_group_reset, false)
				
				for (var v = fxrange[0]; v <= fxrange[1]; v++)
					if (fxtype != e_cam_fx.FADE || v != e_value.GLOW_COLOR)
						tl_value_set(v, tl_value_default(v))
				
				if (camera_effect_type_use_aperture(fxtype))
					for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
						tl_value_set(v, tl_value_default(v))
				
				if (fxtype = e_cam_fx.COLOR_CORRECTION)
					for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
						tl_value_set(v, tl_value_default(v))
				
				if (fxtype = e_cam_fx.LENS_DIRT)
					tl_value_set(e_value.TEXTURE_OBJ, null)
				
				tl_value_set_done()
				
				camera_effect_type_edit = null
			}
			
			break
		}
		
		case e_context_group.EASE:
			action_tl_frame_ease_set_all([ 1, 0, 0, 1 ], false)
			break
	}
}
