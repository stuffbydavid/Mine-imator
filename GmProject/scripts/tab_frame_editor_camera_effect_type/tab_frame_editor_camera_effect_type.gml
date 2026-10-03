/// @arg effecttype

function tab_frame_editor_camera_effect_type(fxtype)
{
	var nameprefix = "frame_editor/camera_effect/";
	context_menu_group_temp = e_context_group.CAMERA
	
	switch (fxtype)
	{
		// Fade in/out
		case e_cam_fx.FADE:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/fade", collapse_map[?"frame_editor/fade"], null, true, nameprefix + "fade", nameprefix + "fade_tip")
			tab_next()
			
			if (collapse_map[?"frame_editor/fade"])
			{
				tab_collapse_start()
				
				tab_control_meter()
				draw_meter(nameprefix + "fade", dx, dy, dw, round(tl_edit.value[e_value.MIX_PERCENT] * 100), 0, 100, 0, 1, tab.camera_effects.tbx_mix_percent, action_tl_frame_cam_fx_fade)
				tab_next()
				
				tab_control_color()
				draw_button_color(nameprefix + "fade/color", dx, dy, dw, tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color)
				tab_next()
				
				tab_collapse_end()
			}
			
			break
		}
		
		// Camera shake
		case e_cam_fx.SHAKE:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/shake", collapse_map[?"frame_editor/shake"], null, true, nameprefix + "shake", nameprefix + "shake/tip")
			tab_next()

			if (collapse_map[?"frame_editor/shake"])
			{
				tab_collapse_start()

				tab_control_meter()
				draw_meter(nameprefix + "shake/amount", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_SHAKE_STRENGTH_X] * 100), 0, 500, 100, 1, tab.camera_effects.tbx_shake_amount, action_tl_frame_cam_fx_shake_amount)
				tab_next()
				
				// Custom
				if (setting_advanced_mode)
				{
					tab_control_switch()
					draw_button_collapse("frame_editor/shake/custom", collapse_map[?"frame_editor/shake/custom"], null, true, nameprefix + "shake/custom")
					tab_next()

					if (collapse_map[?"frame_editor/shake/custom"])
					{
						tab_collapse_start()

						// Mode
						tab_control_togglebutton()
						togglebutton_add(nameprefix + "shake/rotational", null, 0, tl_edit.value[e_value.CAM_FX_SHAKE_MODE] = 0, action_tl_frame_cam_fx_shake_mode)
						togglebutton_add(nameprefix + "shake/positional", null, 1, tl_edit.value[e_value.CAM_FX_SHAKE_MODE] = 1, action_tl_frame_cam_fx_shake_mode)
						draw_togglebutton(nameprefix + "shake/mode", dx, dy)
						tab_next()

						// Strength
						axis_edit = X
						textfield_group_add(nameprefix + "shake/strength/x", round(tl_edit.value[e_value.CAM_FX_SHAKE_STRENGTH_X] * 100), 100, action_tl_frame_cam_fx_shake_strength, axis_edit, tab.camera_effects.tbx_shake_strength_x, null, 1, 0, no_limit)
						axis_edit = (setting_z_is_up ? Y : Z)
						textfield_group_add(nameprefix + "shake/strength/y", round(tl_edit.value[e_value.CAM_FX_SHAKE_STRENGTH_X + axis_edit] * 100), 100, action_tl_frame_cam_fx_shake_strength, axis_edit, tab.camera_effects.tbx_shake_strength_y, null, 1, 0, no_limit)
						axis_edit = (setting_z_is_up ? Z : Y)
						textfield_group_add(nameprefix + "shake/strength/z", round(tl_edit.value[e_value.CAM_FX_SHAKE_STRENGTH_X + axis_edit] * 100), 100, action_tl_frame_cam_fx_shake_strength, axis_edit, tab.camera_effects.tbx_shake_strength_z, null, 1, 0, no_limit)

						tab_control_textfield_group(true)
						draw_textfield_group(nameprefix + "shake/strength", dx, dy, dw, null, null, null, .01, true, true, 1)
						tab_next()

						// Speed
						axis_edit = X
						textfield_group_add(nameprefix + "shake/speed/x", round(tl_edit.value[e_value.CAM_FX_SHAKE_SPEED_X] * 100), 100, action_tl_frame_cam_fx_shake_speed, axis_edit, tab.camera_effects.tbx_shake_speed_x, null, 1, 0, no_limit)
						axis_edit = (setting_z_is_up ? Y : Z)
						textfield_group_add(nameprefix + "shake/speed/y", round(tl_edit.value[e_value.CAM_FX_SHAKE_SPEED_X + axis_edit] * 100), 100, action_tl_frame_cam_fx_shake_speed, axis_edit, tab.camera_effects.tbx_shake_speed_y, null, 1, 0, no_limit)
						axis_edit = (setting_z_is_up ? Z : Y)
						textfield_group_add(nameprefix + "shake/speed/z", round(tl_edit.value[e_value.CAM_FX_SHAKE_SPEED_X + axis_edit] * 100), 100, action_tl_frame_cam_fx_shake_speed, axis_edit, tab.camera_effects.tbx_shake_speed_z, null, 1, 0, no_limit)

						tab_control_textfield_group(true)
						draw_textfield_group(nameprefix + "shake/speed", dx, dy, dw, null, null, null, .01, true, true, 1)
						tab_next()

						tab_collapse_end(false)
					}
				}

				tab_collapse_end()
			}
			
			break
		}
		
		// Depth of field
		case e_cam_fx.DOF:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/dof", collapse_map[?"frame_editor/dof"], null, true, nameprefix + "dof", nameprefix + "dof/tip")
			tab_next()

			if (collapse_map[?"frame_editor/dof"])
			{
				tab_collapse_start()

				draw_set_font(font_label)
				draw_label(string_limit(text_get(nameprefix + "dof/focus") + ":", dw), dx, dy - 3, fa_left, fa_top, c_text_secondary, a_text_secondary)
				
				tab_control_togglebutton()
				togglebutton_add(nameprefix + "dof/foreground", icons.PLAYER, 0, (tl_edit.value[e_value.CAM_FX_DOF_DEPTH] = 0 && tl_edit.value[e_value.CAM_FX_DOF_RANGE] = 100), action_tl_frame_cam_fx_dof_preset)
				togglebutton_add(nameprefix + "dof/background", icons.SCENERY, 1, (tl_edit.value[e_value.CAM_FX_DOF_DEPTH] = project_render_distance && tl_edit.value[e_value.CAM_FX_DOF_RANGE] = project_render_distance - 200), action_tl_frame_cam_fx_dof_preset)
				draw_togglebutton(nameprefix + "dof/focus", dx, dy + label_height + 8, true, false)
				tab_next()

				tab_control(ui_large_height)
				togglebutton_add(nameprefix + "dof/pick_focus_point", icons.PICKER, null, window_busy = "pick_depth", action_tl_frame_cam_fx_dof_pick)
				draw_togglebutton(nameprefix + "dof/pick_focus_point", dx, dy, true, false)
				tab_next()

				if (setting_advanced_mode)
				{
					tab_control_switch()
					draw_button_collapse("frame_editor/dof_custom", collapse_map[?"frame_editor/dof_custom"], null, true, nameprefix + "dof/custom")
					tab_next()

					if (collapse_map[?"frame_editor/dof_custom"])
					{
						tab_collapse_start()

						tab_control_dragger()
						draw_dragger(nameprefix + "dof/depth", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_DOF_DEPTH]), max(0.5, tl_edit.value[e_value.CAM_FX_DOF_DEPTH] / 50), 0, project_render_distance, 0, 1, tab.camera_effects.tbx_dof_depth, action_tl_frame_cam_fx_dof_depth)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "dof/range", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_DOF_RANGE]), max(0.5, tl_edit.value[e_value.CAM_FX_DOF_RANGE] / 50), 0, no_limit, 200, 1, tab.camera_effects.tbx_dof_range, action_tl_frame_cam_fx_dof_range)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "dof/fade_size", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_DOF_FADE_SIZE], 2, 0, no_limit, 100, 0, tab.camera_effects.tbx_dof_fade_size, action_tl_frame_cam_fx_dof_fade_size)
						tab_next()

						tab_control_meter()
						draw_meter(nameprefix + "dof/blur_size", dx, dy, dw, tl_edit.value[e_value.CAM_FX_DOF_BLUR_SIZE] * 100, 0, 10, 1.5, .01, tab.camera_effects.tbx_dof_blur_size, action_tl_frame_cam_fx_dof_blur_size)
						tab_next()

						tab_collapse_end(false)
					}
					
					tab_control_switch()
					draw_button_collapse("frame_editor/dof_bokeh", collapse_map[?"frame_editor/dof_bokeh"], null, true, nameprefix + "dof/bokeh")
					tab_next()

					if (collapse_map[?"frame_editor/dof_bokeh"])
					{
						tab_collapse_start()

						tab_control_meter()
						draw_meter(nameprefix + "dof/blur_ratio", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_DOF_BLUR_RATIO] * 100), -100, 100, 0, 1, tab.camera_effects.tbx_dof_blur_ratio, action_tl_frame_cam_fx_dof_blur_ratio)
						tab_next()

						tab_control_meter()
						draw_meter(nameprefix + "dof/bias", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_DOF_BIAS] * 10), 0, 100, 0, 1, tab.camera_effects.tbx_dof_bias, action_tl_frame_cam_fx_dof_bias)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "dof/threshold", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_DOF_THRESHOLD] * 100, .1, 0, no_limit * 100, 0, .1, tab.camera_effects.tbx_dof_threshold, action_tl_frame_cam_fx_dof_threshold)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "dof/gain", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_DOF_GAIN] * 100, .1, 0, no_limit * 100, 0, .1, tab.camera_effects.tbx_dof_gain, action_tl_frame_cam_fx_dof_gain)
						tab_next()

						tab_collapse_end(false)
					}

					tab_control_switch()
					draw_button_collapse("frame_editor/dof_fringe", collapse_map[?"frame_editor/dof_fringe"], action_tl_frame_cam_fx_dof_fringe, tl_edit.value[e_value.CAM_FX_DOF_FRINGE], nameprefix + "dof/fringe")
					tab_next()

					if (tl_edit.value[e_value.CAM_FX_DOF_FRINGE] && collapse_map[?"frame_editor/dof_fringe"])
					{
						tab_collapse_start()

						var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);

						// Wheels
						if (!app.panel_compact)
						{
							tab_control_wheel()
							axis_edit = X
							draw_wheel(nameprefix + "doffringeangleredwheel", floor(dx + dw/6), dy + 24, c_axisred, tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_RED], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_RED], snapval, tab.camera_effects.tbx_dof_fringe_angle_red, action_tl_frame_cam_fx_dof_fringe_angle)
							axis_edit = Y
							draw_wheel(nameprefix + "doffringeanglegreenwheel", floor(dx + dw/2), dy + 24, c_axisgreen, tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_GREEN], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_GREEN], snapval, tab.camera_effects.tbx_dof_fringe_angle_green, action_tl_frame_cam_fx_dof_fringe_angle)
							axis_edit = Z
							draw_wheel(nameprefix + "doffringeanglebluewheel", floor(dx + dw - dw/6), dy + 24, c_axisblue, tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_BLUE], -no_limit, no_limit, tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_BLUE], snapval, tab.camera_effects.tbx_dof_fringe_angle_blue, action_tl_frame_cam_fx_dof_fringe_angle)
							tab_next()
						}

						// Textboxes
						axis_edit = X
						textfield_group_add(nameprefix + "dof/fringe/angle_red", tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_RED], tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_RED], action_tl_frame_cam_fx_dof_fringe_angle, axis_edit, tab.camera_effects.tbx_dof_fringe_angle_red)
						axis_edit = Y
						textfield_group_add(nameprefix + "dof/fringe/angle_green", tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_GREEN], tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_GREEN], action_tl_frame_cam_fx_dof_fringe_angle, axis_edit, tab.camera_effects.tbx_dof_fringe_angle_green)
						axis_edit = Z
						textfield_group_add(nameprefix + "dof/fringe/angle_blue", tl_edit.value[e_value.CAM_FX_DOF_FRINGE_ANGLE_BLUE], tl_edit.value_default[e_value.CAM_FX_DOF_FRINGE_ANGLE_BLUE], action_tl_frame_cam_fx_dof_fringe_angle, axis_edit, tab.camera_effects.tbx_dof_fringe_angle_blue)

						tab_control_textfield_group()
						draw_textfield_group(nameprefix + "doffringeangle", dx, dy, dw, 0.1, -no_limit, no_limit, snapval, false, true, 3)
						tab_next()

						// Offset
						axis_edit = X
						textfield_group_add(nameprefix + "dof/fringe/red", round(tl_edit.value[e_value.CAM_FX_DOF_FRINGE_RED] * 100), 100, action_tl_frame_cam_fx_dof_fringe_red, axis_edit, tab.camera_effects.tbx_dof_fringe_red)
						axis_edit = Y
						textfield_group_add(nameprefix + "dof/fringe/green", round(tl_edit.value[e_value.CAM_FX_DOF_FRINGE_GREEN] * 100), 100, action_tl_frame_cam_fx_dof_fringe_green, axis_edit, tab.camera_effects.tbx_dof_fringe_green)
						axis_edit = Z
						textfield_group_add(nameprefix + "dof/fringe/blue", round(tl_edit.value[e_value.CAM_FX_DOF_FRINGE_BLUE] * 100), 100, action_tl_frame_cam_fx_dof_fringe_blue, axis_edit, tab.camera_effects.tbx_dof_fringe_blue)

						tab_control_textfield_group(true)
						draw_textfield_group(nameprefix + "dof/fringe/offset", dx, dy, dw, 1, 0, no_limit, 1, true, true, 3)
						tab_next()

						tab_collapse_end(false)
					}
				}

				tab_collapse_end()
			}
			
			break
		}
		
		// Bloom
		case e_cam_fx.BLOOM:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/bloom", collapse_map[?"frame_editor/bloom"], null, true, nameprefix + "bloom", nameprefix + "bloom/tip")
			tab_next()

			if (collapse_map[?"frame_editor/bloom"])
			{
				tab_collapse_start()

				tab_control_meter()
				draw_meter(nameprefix + "bloom/amount", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_BLOOM_INTENSITY] * 100), 0, 500, 100, 1, tab.camera_effects.tbx_bloom_amount, action_tl_frame_cam_fx_bloom_amount)
				tab_next()

				if (setting_advanced_mode)
				{
					tab_control_switch()
					draw_button_collapse("frame_editor/bloom/custom", collapse_map[?"frame_editor/bloom/custom"], null, true, nameprefix + "bloom/custom")
					tab_next()

					if (collapse_map[?"frame_editor/bloom/custom"])
					{
						tab_collapse_start()

						tab_control_dragger()
						draw_dragger(nameprefix + "bloom/radius", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_BLOOM_RADIUS] * 100), 1, 0, no_limit, 100, 1, tab.camera_effects.tbx_bloom_radius, action_tl_frame_cam_fx_bloom_radius)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "bloom/intensity", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_BLOOM_INTENSITY] * 100), 1, 0, no_limit, 100, 1, tab.camera_effects.tbx_bloom_intensity, action_tl_frame_cam_fx_bloom_intensity)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "bloom/threshold", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_BLOOM_THRESHOLD], 0.01, 0, no_limit, 0.85, 0.01, tab.camera_effects.tbx_bloom_threshold, action_tl_frame_cam_fx_bloom_threshold)
						tab_next()

						tab_control_dragger()
						draw_dragger(nameprefix + "bloom/transition", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_BLOOM_TRANSITION], 0.01, 0, no_limit, 0.5, 0.01, tab.camera_effects.tbx_bloom_transition, action_tl_frame_cam_fx_bloom_transition)
						tab_next()

						tab_control_meter()
						draw_meter(nameprefix + "bloom/ratio", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_BLOOM_RATIO] * 100), 0, 100, 0, 1, tab.camera_effects.tbx_bloom_ratio, action_tl_frame_cam_fx_bloom_ratio)
						tab_next()

						tab_control_color()
						draw_button_color(nameprefix + "bloom/blend", dx, dy, dw, tl_edit.value[e_value.CAM_FX_BLOOM_BLEND], c_white, false, action_tl_frame_cam_fx_bloom_blend)
						tab_next()

						tab_collapse_end(false)
					}
				}

				tab_collapse_end()
			}
			
			break
		}
		
		// Lens dirt
		case e_cam_fx.LENS_DIRT:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/lens_dirt", collapse_map[?"frame_editor/lens_dirt"], null, true, nameprefix + "lens_dirt", nameprefix + "lens_dirt/tip")
			tab_next()

			if (collapse_map[?"frame_editor/lens_dirt"])
			{
				tab_collapse_start()

				// Lens dirt texture(TEXTURE_OBJ)
				var texobj, tex;
				texobj = tl_edit.value[e_value.TEXTURE_OBJ]
				tex = null

				if (texobj != null)
					content_text = texobj.display_name
				else
					content_text = text_get("list/none")

				if (texobj = null)
					content_text = text_get("list/default", content_text)

				if (texobj != null && texobj.type != e_tl_type.CAMERA) // Don't preview cameras
					tex = texobj.texture

				tab_control_menu(ui_large_height)
				draw_button_menu(nameprefix + "lens_dirt/texture", e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_OBJ], content_text, action_tl_frame_texture_obj, false, tex)
				tab_next()

				// Affected by bloom
				tab_control_switch()
				draw_switch(nameprefix + "lens_dirt/bloom", dx, dy, tl_edit.value[e_value.CAM_FX_LENS_DIRT_BLOOM], action_tl_frame_cam_fx_lens_dirt_bloom)
				tab_next()

				// Affected by glow
				tab_control_switch()
				draw_switch(nameprefix + "lens_dirt/glow", dx, dy, tl_edit.value[e_value.CAM_FX_LENS_DIRT_GLOW], action_tl_frame_cam_fx_lens_dirt_glow)
				tab_next()

				// Radius
				tab_control_meter()
				draw_meter(nameprefix + "lens_dirt/radius", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_LENS_DIRT_RADIUS] * 100), 0, 300, 50, 1, tab.camera_effects.tbx_lens_dirt_radius, action_tl_frame_cam_fx_lens_dirt_radius)
				tab_next()

				// Intensity
				tab_control_meter()
				draw_meter(nameprefix + "lens_dirt/intensity", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_LENS_DIRT_INTENSITY] * 100), 0, 200, 80, 1, tab.camera_effects.tbx_lens_dirt_intensity, action_tl_frame_cam_fx_lens_dirt_intensity)
				tab_next()

				// Power
				tab_control_meter()
				draw_meter(nameprefix + "lens_dirt/power", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_LENS_DIRT_POWER] * 100), 100, 500, 150, 1, tab.camera_effects.tbx_lens_dirt_power, action_tl_frame_cam_fx_lens_dirt_power)
				tab_next()

				tab_collapse_end()
			}
			
			break
		}
		
		// Film grain
		case e_cam_fx.GRAIN:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/grain", collapse_map[?"frame_editor/grain"], null, true, nameprefix + "grain", nameprefix + "grain/tip")
			tab_next()

			if (collapse_map[?"frame_editor/grain"])
			{
				tab_collapse_start()

				tab_control_meter()
				draw_meter(nameprefix + "grain/strength", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_GRAIN_STRENGTH] * 100), -100, 100, 10, 1, tab.camera_effects.tbx_grain_strength, action_tl_frame_cam_fx_grain_strength)
				tab_next()

				tab_control_meter()
				draw_meter(nameprefix + "grain/saturation", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_GRAIN_SATURATION] * 100), 0, 100, 10, 1, tab.camera_effects.tbx_grain_saturation, action_tl_frame_cam_fx_grain_saturation)
				tab_next()

				tab_control_meter()
				draw_meter(nameprefix + "grain/size", dx, dy, dw, tl_edit.value[e_value.CAM_FX_GRAIN_SIZE], 1, 10, 1, 1, tab.camera_effects.tbx_grain_size, action_tl_frame_cam_fx_grain_size)
				tab_next()

				tab_collapse_end()
			}
			
			break
		}
		
		// Vignette
		case e_cam_fx.VIGNETTE:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/vignette", collapse_map[?"frame_editor/vignette"], null, true, nameprefix + "vignette", nameprefix + "vignette/tip")
			tab_next()

			if (collapse_map[?"frame_editor/vignette"])
			{
				tab_collapse_start()

				tab_control_meter()
				draw_meter(nameprefix + "vignette/radius", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_VIGNETTE_RADIUS] * 100), 0, 100, 100, 1, tab.camera_effects.tbx_vignette_radius, action_tl_frame_cam_fx_vignette_radius)
				tab_next()

				tab_control_meter()
				draw_meter(nameprefix + "vignette/softness", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_VIGNETTE_SOFTNESS] * 100), 0, 100, 50, 1, tab.camera_effects.tbx_vignette_softness, action_tl_frame_cam_fx_vignette_softness)
				tab_next()

				tab_control_meter()
				draw_meter(nameprefix + "vignette/strength", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_VIGNETTE_STRENGTH] * 100), 0, 100, 100, 1, tab.camera_effects.tbx_vignette_strength, action_tl_frame_cam_fx_vignette_strength)
				tab_next()

				tab_control_color()
				draw_button_color(nameprefix + "vignette/color", dx, dy, dw, tl_edit.value[e_value.CAM_FX_VIGNETTE_COLOR], c_black, false, action_tl_frame_cam_fx_vignette_color)
				tab_next()

				tab_collapse_end()
			}
			
			break
		}
		
		// Chromatic aberration
		case e_cam_fx.CA:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/ca", collapse_map[?"frame_editor/ca"], null, true, nameprefix + "ca", nameprefix + "ca/tip")
			tab_next()

			if (collapse_map[?"frame_editor/ca"])
			{
				tab_collapse_start()

				tab_control_meter()
				draw_meter(nameprefix + "ca/blur_amount", dx, dy, dw, round(tl_edit.value[e_value.CAM_FX_CA_BLUR_AMOUNT] * 100), 0, 100, 5, 1, tab.camera_effects.tbx_ca_blur_amount, action_tl_frame_cam_fx_ca_blur_amount)
				tab_next()

				tab_control_switch()
				draw_switch(nameprefix + "ca/distort_channels", dx, dy, tl_edit.value[e_value.CAM_FX_CA_DISTORT_CHANNELS], action_tl_frame_cam_fx_ca_distort_channels)
				tab_next()

				textfield_group_add(nameprefix + "ca/red_offset", round(tl_edit.value[e_value.CAM_FX_CA_RED_OFFSET] * 100), 12, action_tl_frame_cam_fx_ca_red_offset, X, tab.camera_effects.tbx_ca_red_offset)
				textfield_group_add(nameprefix + "ca/green_offset", round(tl_edit.value[e_value.CAM_FX_CA_GREEN_OFFSET] * 100), 8, action_tl_frame_cam_fx_ca_green_offset, X, tab.camera_effects.tbx_ca_green_offset)
				textfield_group_add(nameprefix + "ca/blue_offset", round(tl_edit.value[e_value.CAM_FX_CA_BLUE_OFFSET] * 100), 4, action_tl_frame_cam_fx_ca_blue_offset, X, tab.camera_effects.tbx_ca_blue_offset)

				tab_control_textfield_group(true)
				draw_textfield_group(nameprefix + "ca/offset", dx, dy, dw, 1, 0, no_limit, 1, true, true, 3)
				tab_next()

				tab_collapse_end()
			}
			
			break
		}
		
		// Distort
		case e_cam_fx.DISTORT:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/distort", collapse_map[?"frame_editor/distort"], null, true, nameprefix + "distort", nameprefix + "distort/tip")
			tab_next()

			if (collapse_map[?"frame_editor/distort"])
			{
				tab_collapse_start()

				tab_control_switch()
				draw_switch(nameprefix + "distort/repeat", dx, dy, tl_edit.value[e_value.CAM_FX_DISTORT_REPEAT], action_tl_frame_cam_fx_distort_repeat)
				tab_next()

				tab_control_dragger()
				draw_dragger(nameprefix + "distort/zoom", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_DISTORT_ZOOM_AMOUNT] * 100, 1, snap_min, no_limit, 100, .01, tab.camera_effects.tbx_distort_zoom_amount, action_tl_frame_cam_fx_distort_zoom_amount)
				tab_next()

				tab_control_dragger()
				draw_dragger(nameprefix + "distort/amount", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_DISTORT_AMOUNT] * 100, .1, -no_limit * 100, no_limit * 100, 5, 0.01, tab.camera_effects.tbx_distort_amount, action_tl_frame_cam_fx_distort_amount)
				tab_next()

				tab_collapse_end(false)
			}
			
			break
		}
		
		case e_cam_fx.LIGHT_MANAGEMENT:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/light_management", collapse_map[?"frame_editor/light_management"], null, true, nameprefix + "light_management", nameprefix + "light_management/tip")
			tab_next()
			
			if (collapse_map[?"frame_editor/light_management"])
			{
				tab_collapse_start()
				
				var tonemapper = tl_edit.value[e_value.CAM_FX_TONEMAPPER];
				if (tonemapper >= 0 && tonemapper < array_length(render_tonemapper_names))
					content_text = text_get("render/tonemapper/" + render_tonemapper_names[tonemapper])
				else
					content_text = text_get("render/tonemapper/none")
				
				tab_control_menu()
				draw_button_menu("render/tonemapper", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.CAM_FX_TONEMAPPER], content_text, action_tl_frame_cam_fx_tonemapper)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "light_management/exposure", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_EXPOSURE], 0.01, 0, no_limit, 1, 0.01, tab.camera_effects.tbx_exposure, action_tl_frame_cam_fx_exposure)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "light_management/gamma", dx, dy, dragger_width, tl_edit.value[e_value.CAM_FX_GAMMA], 0.01, 0, no_limit, 2.2, 0.01, tab.camera_effects.tbx_gamma, action_tl_frame_cam_fx_gamma)
				tab_next()
				
				tab_collapse_end()
			}
			
			break
		}
		
		// Color correction+properties
		case e_cam_fx.COLOR_CORRECTION:
		{
			tab_control_switch()
			draw_button_collapse("frame_editor/color_correction", collapse_map[?"frame_editor/color_correction"], null, true, nameprefix + "color_correction", nameprefix + "color_correction/tip")
			tab_next()
			
			if (collapse_map[?"frame_editor/color_correction"])
			{
				tab_collapse_start()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "color_correction/contrast", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_CONTRAST] * 100), .1, 0, no_limit * 100, 0, 1, tab.camera_effects.tbx_contrast, action_tl_frame_cam_fx_clrcor_contrast)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "color_correction/brightness", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_BRIGHTNESS] * 100), .1, -no_limit * 100, no_limit * 100, 0, 1, tab.camera_effects.tbx_brightness, action_tl_frame_cam_fx_clrcor_brightness)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "color_correction/saturation", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_SATURATION] * 100), .1, 0, no_limit * 100, 100, 1, tab.camera_effects.tbx_saturation, action_tl_frame_cam_fx_clrcor_saturation)
				tab_next()
				
				tab_control_dragger()
				draw_dragger(nameprefix + "color_correction/vibrance", dx, dy, dragger_width, round(tl_edit.value[e_value.CAM_FX_VIBRANCE] * 100), .1, 0, no_limit * 100, 0, 1, tab.camera_effects.tbx_vibrance, action_tl_frame_cam_fx_clrcor_vibrance)
				tab_next()
				
				tab_control_color()
				draw_button_color(nameprefix + "color_correction/color_burn", dx, dy, dw, tl_edit.value[e_value.CAM_FX_COLOR_BURN], c_white, false, action_tl_frame_cam_fx_clrcor_color_burn)
				tab_next()
				
				tab_frame_editor_color(null, false)
				
				tab_collapse_end()
			}
			
			break
		}
	}
	
	context_menu_group_temp = null
}
