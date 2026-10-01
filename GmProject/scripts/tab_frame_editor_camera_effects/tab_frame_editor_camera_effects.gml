function tab_frame_editor_camera_effects()
{
	var tl, fxtl, aperturetype;
	tl = tl_edit
	fxtl = array_create(e_cam_fx.amount, null)
	aperturetype = null
	
	with (obj_timeline)
		if (selected && type = e_tl_type.CAMERA_EFFECT && fxtl[camera_effect_type] = null)
			fxtl[camera_effect_type] = id
	
	for (var fxtype = 0; fxtype < e_cam_fx.amount; fxtype++)
	{
		if (fxtl[fxtype] = null)
			continue
		
		if (camera_effect_type_use_aperture(fxtype) && (aperturetype = null || fxtype = e_cam_fx.BLOOM))
			aperturetype = fxtype
		
		tl_edit = fxtl[fxtype]
		camera_effect_type_edit = fxtype
		
		tab_frame_editor_camera_effect_type(fxtype)
	}
	
	// Aperture settings (Bloom/DOF)
	if (setting_advanced_mode && aperturetype != null)
	{
		var nameprefix = "frameeditorcameraeffectaperture";
		 
		tl_edit = fxtl[aperturetype]
		camera_effect_type_edit = aperturetype
		context_menu_group_temp = e_context_group.CAMERA
		
		tab_control_switch()
		draw_button_collapse("aperture", collapse_map[?"aperture"], null, true, nameprefix, nameprefix + "tip")
		tab_next()
		
		if (collapse_map[?"aperture"])
		{
			tab_collapse_start()
			
			tab_control_meter()
			draw_meter(nameprefix + "bladeamount", dx, dy, dw, tl_edit.value[e_value.CAM_FX_BLADE_AMOUNT], 0, 16, 0, 1, tab.camera_effects.tbx_blade_amount, action_tl_frame_cam_fx_blade_amount)
			tab_next()
			
			tab_control_dragger()
			draw_dragger(nameprefix + "bladeangle", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_BLADE_ANGLE], 1, -no_limit, no_limit, 0, 0.1, tab.camera_effects.tbx_blade_angle, action_tl_frame_cam_fx_blade_angle)
			tab_next()
			
			tab_control_meter()
			draw_meter(nameprefix + "bladestretch", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_BLADE_STRETCH] * 100), -100, 100, 0, 1, tab.camera_effects.tbx_blade_stretch, action_tl_frame_cam_fx_blade_stretch)
			tab_next()
			
			tab_collapse_end()
		}
		
		context_menu_group_temp = null
	}
	
	camera_effect_type_edit = null
	tl_edit = tl
}
