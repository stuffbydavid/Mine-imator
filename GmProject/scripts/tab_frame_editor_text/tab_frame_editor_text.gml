/// tab_frame_editor_text()

function tab_frame_editor_text()
{
	if (tl_edit.temp = null || tl_edit.type != e_tl_type.TEXT)
		return 0
	
	// Text
	tab_control_textfield(true, 126)
	tab.text.tbx_text.text = tl_edit.value[e_value.TEXT]
	draw_textfield("frameeditortexttext", dx, dy, dw, 126, tab.text.tbx_text, action_tl_frame_text, tl_edit.value_default[e_value.TEXT], "top")
	tab_next()

	// Font
	if (setting_advanced_mode)
	{
		if (!tl_edit.has_temp)
		{
			tab_control_menu(ui_large_height)
			draw_button_menu("frameeditortextfont", e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.text_font, res_eval(tl_edit.text_font).display_name, action_tl_text_font)
			tab_next()
		}
		else
		{
			var text;
			if (tl_edit.value[e_value.TEXT_FONT] = null)
				text = text_get("listdefault", res_eval(tl_edit.temp.text_font).display_name)
			else
				text = res_eval(tl_edit.value[e_value.TEXT_FONT]).display_name

			tab_control_menu(ui_large_height)
			draw_button_menu("frameeditortextfont", e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXT_FONT], text, action_tl_frame_text_font)
			tab_next()
		}
	}
	
	// Font Anti-aliasing
	if (!tl_edit.has_temp && setting_advanced_mode && res_eval(tl_edit.text_font).type = e_res_type.FONT)
	{
		tab_control_switch()
		draw_switch("frameeditortextaa", dx, dy, tl_edit.text_aa, action_tl_text_aa, "frameeditortextaatip")
		tab_next()
	}

	// 3D and face camera
	if (!tl_edit.has_temp)
	{
		var sx = dx_start;
		dx_start = dx
		tab_set_collumns(true, 2)

		tab_control_checkbox()
		draw_checkbox("frameeditortext3d", dx, dy, tl_edit.text_3d, action_tl_text_3d)
		tab_next()

		tab_control_checkbox()
		draw_checkbox("frameeditortextfacecamera", dx, dy, tl_edit.text_face_camera, action_tl_text_face_camera)
		tab_next()

		tab_set_collumns(false)
		dx_start = sx
	}
	
	// Text outline
	var outlinescript, outlineactive, outlinetext;
	if (tl_edit.has_temp)
	{
		outlinescript = action_tl_frame_text_custom_outline
		outlineactive = tl_edit.value[e_value.TEXT_CUSTOM_OUTLINE]
		outlinetext = "frameeditortextcustomoutline"
	}
	else
	{
		outlinescript = action_tl_frame_text_outline
		outlineactive = tl_edit.value[e_value.TEXT_OUTLINE]
		outlinetext = "frameeditortextoutline"
	}
	tab_control_switch()
	draw_button_collapse("textoutline", collapse_map[?"textoutline"], outlinescript, outlineactive, outlinetext)
	tab_next()
	
	if (outlineactive && collapse_map[?"textoutline"])
	{
		tab_collapse_start()
		
		if (tl_edit.has_temp)
		{
			tab_control_switch()
			draw_switch("frameeditortextoutline", dx, dy, tl_edit.value[e_value.TEXT_OUTLINE], action_tl_frame_text_outline)
			tab_next()
		}
		
		if (tl_edit.value[e_value.TEXT_OUTLINE])
		{
			tab_control_color(true)
			draw_button_color("frameeditortextoutlinecolor", dx, dy, dw, tl_edit.value[e_value.TEXT_OUTLINE_COLOR], tl_edit.value_default[e_value.TEXT_OUTLINE_COLOR], false, action_tl_frame_text_outline_color, true)
			tab_next()
			var fontres = tl_edit.temp.text_font;
			if (tl_edit.has_temp && tl_edit.value[e_value.TEXT_FONT] != null)
				fontres = tl_edit.value[e_value.TEXT_FONT]
			if (res_eval(fontres).type = e_res_type.FONT)
			{
				tab_control_dragger()
				draw_dragger("frameeditortextoutlinesize", dx, dy, dragger_width, tl_edit.value[e_value.TEXT_OUTLINE_SIZE], 0.1, 0, 8, tl_edit.value_default[e_value.TEXT_OUTLINE_SIZE], 1, tab.text.tbx_outline_size, action_tl_frame_text_outline_size)
				tab_next()
			}
		}
		
		tab_collapse_end()
	}
	
	// Alignment
	if (setting_advanced_mode)
	{
		if (tl_edit.has_temp)
		{
			tab_control_switch()
			draw_button_collapse("textalignment", collapse_map[?"textalignment"], action_tl_frame_text_custom_alignment, tl_edit.value[e_value.TEXT_CUSTOM_ALIGNMENT], "frameeditortextcustomalignment")
			tab_next()
			
			if (tl_edit.value[e_value.TEXT_CUSTOM_ALIGNMENT] && collapse_map[?"textalignment"])
			{
				tab_collapse_start()
				draw_text_alignment("frameeditortext", "", tl_edit.value[e_value.TEXT_HALIGN], tl_edit.value[e_value.TEXT_VALIGN], action_tl_frame_text_halign, action_tl_frame_text_valign)
				tab_collapse_end()
			}
		}
		else
			draw_text_alignment("frameeditortext", "frameeditortextalignment", tl_edit.value[e_value.TEXT_HALIGN], tl_edit.value[e_value.TEXT_VALIGN], action_tl_frame_text_halign, action_tl_frame_text_valign)
	}
}
