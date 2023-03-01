/// tab_frame_editor_ik()

function tab_frame_editor_ik()
{
	if (tl_edit.type != e_tl_type.BODYPART || !tl_edit.value_type[e_value_type.TRANSFORM_BEND] || tl_edit.model_part = null || tl_edit.model_part.ik_supported = false)
		return 0
	
	tab_control_switch()
	draw_button_collapse("ik", collapse_map[?"ik"], null, true, "frameeditorik", "frameeditoriktip")
	tab_next()
	
	if (collapse_map[?"ik"])
	{
		tab_collapse_start()
		
		var text;
		
		// Target object
		if (tl_edit.value[e_value.IK_TARGET] != null)
			text = tl_edit.value[e_value.IK_TARGET].display_name
		else
			text = text_get("listnone")
		
		tab_control_menu()
		draw_button_menu("frameeditoriktarget", e_menu.TIMELINE, dx, dy, dw, 24, tl_edit.value[e_value.IK_TARGET], text, action_tl_frame_ik_target)
		tab_next()
		
		// Pole target object
		if (tl_edit.value[e_value.IK_TARGET_ANGLE] != null)
			text = tl_edit.value[e_value.IK_TARGET_ANGLE].display_name
		else
			text = text_get("listnone")
		
		tab_control_menu()
		draw_button_menu("frameeditorikangletarget", e_menu.TIMELINE, dx, dy, dw, 24, tl_edit.value[e_value.IK_TARGET_ANGLE], text, action_tl_frame_ik_target_angle, tl_edit.value[e_value.IK_TARGET] = null)
		tab_next()
		
		// Angle offset
		tab_control_dragger()
		draw_dragger("frameeditorikangleoffset", dx, dy, dragger_width, tl_edit.value[e_value.IK_ANGLE_OFFSET], 0.1, -no_limit, no_limit, 0, snap_min, tab.constraints.tbx_ik_angle_offset, action_tl_frame_ik_angle_offset, null, true, tl_edit.value[e_value.IK_TARGET] = null || tl_edit.value[e_value.IK_TARGET_ANGLE] = null)
		tab_next()
		
		// Blend
		tab_control_meter()
		draw_meter("frameeditorikblend", dx, dy, dw, round(tl_edit.value[e_value.IK_BLEND] * 100), 0, 100, 100, 1, tab.constraints.tbx_ik_blend, action_tl_frame_ik_blend)
		tab_next()
		
		tab_collapse_end()
	}
}