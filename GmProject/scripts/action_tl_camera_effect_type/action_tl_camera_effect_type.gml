/// @arg effecttype

function action_tl_camera_effect_type(fxtype)
{
	if (history_undo || history_redo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					camera_effect_type = history_undo ? other.save_var_old_value[t] : other.save_var_new_value[t]
					tl_update_type_name()
					tl_update_display_name()
				}
			}
		}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_camera_effect_type, false);
		with (obj_timeline)
		{
			if (!selected || type != e_tl_type.CAMERA_EFFECT || camera_effect_type = fxtype)
				continue
			
			with (hobj)
				history_save_var(other.id, other.camera_effect_type, fxtype)
			
			camera_effect_type = fxtype
			
			tl_update_type_name()
			tl_update_display_name()
		}
	}
	
	app.timeline_camera_effect_value = null
	app.timeline_camera_effect_enabled = null
	
	timeline_marker_previous = -1
	
	app_update_tl_edit()
}
