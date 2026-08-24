/// tab_frame_editor_text()

function tab_frame_editor_text()
{
	if (tl_edit.temp = null || tl_edit.type != e_tl_type.TEXT)
		return 0
	
	// Font
	var text;
	if (tl_edit.value[e_value.TEXT_FONT] = null)
		text = text_get("listdefault", tl_edit.temp.text_font.display_name)
	else
		text = tl_edit.value[e_value.TEXT_FONT].display_name
	
	tab_control_menu()
	draw_button_menu("frameeditortextfont", e_menu.LIST, dx, dy, dw, 24, tl_edit.value[e_value.TEXT_FONT], text, action_tl_frame_text_font)
	tab_next()
	
	// Font Anti-aliasing
	tab_control_switch()
	draw_switch("frameeditortextaa", dx, dy, tl_edit.value[e_value.TEXT_AA], action_tl_frame_text_aa, "frameeditortextaatip")
	tab_next()
	
	// Text outline
	tab_control_switch()
	draw_button_collapse("textoutline", collapse_map[?"textoutline"], action_tl_frame_text_outline, tl_edit.value[e_value.TEXT_OUTLINE], "frameeditortextoutline")
	tab_next()
	
	if (tl_edit.value[e_value.TEXT_OUTLINE] && collapse_map[?"textoutline"])
	{
		tab_collapse_start()
		
		tab_control_color()
		draw_button_color("frameeditortextoutlinecolor", dx, dy, dw, tl_edit.value[e_value.TEXT_OUTLINE_COLOR], tl_edit.value_default[e_value.TEXT_OUTLINE_COLOR], false, action_tl_frame_text_outline_color)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Alignment
	dy += 20
	draw_label(text_get("frameeditortextalignment") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
	dy += 8
	
	var dwold, dxold;
	dwold = dw
	dxold = dx
	
	dw = floor(dw/2 - 4)
	
	// Horizontal
	tab_control_togglebutton()
	togglebutton_add("frameeditortextleft", icons.TEXT_ALIGN_LEFT, "left", tl_edit.value[e_value.TEXT_HALIGN] = "left", action_tl_frame_text_halign)
	togglebutton_add("frameeditortextcenter", icons.TEXT_ALIGN_CENTER, "center", tl_edit.value[e_value.TEXT_HALIGN] = "center", action_tl_frame_text_halign)
	togglebutton_add("frameeditortextright", icons.TEXT_ALIGN_RIGHT, "right", tl_edit.value[e_value.TEXT_HALIGN] = "right", action_tl_frame_text_halign)
	draw_togglebutton("frameeditortexthalign", dx, dy, false)
	
	dx += (dw + 8)
	
	// Vertical
	togglebutton_add("frameeditortexttop", icons.ALIGN_TOP, "top", tl_edit.value[e_value.TEXT_VALIGN] = "top", action_tl_frame_text_valign)
	togglebutton_add("frameeditortextcenter", icons.ALIGN_MIDDLE, "center", tl_edit.value[e_value.TEXT_VALIGN] = "center", action_tl_frame_text_valign)
	togglebutton_add("frameeditortextbottom", icons.ALIGN_BOTTOM, "bottom", tl_edit.value[e_value.TEXT_VALIGN] = "bottom", action_tl_frame_text_valign)
	draw_togglebutton("frameeditortextvalign", dx, dy, false)
	tab_next()
	
	dw = dwold
	dx = dxold
	
	// Text
	tab_control_textfield(true, 76)
	tab.text.tbx_text.text = tl_edit.value[e_value.TEXT]
	draw_textfield("frameeditortexttext", dx, dy, dw, 76, tab.text.tbx_text, action_tl_frame_text, tl_edit.text, "top")
	tab_next()
}
