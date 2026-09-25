/// tab_properties_library_text()

function tab_properties_library_text()
{
	// Font (Advanced mode only)
	if (setting_advanced_mode)
	{
		tab_control_menu(ui_large_height)
		draw_button_menu("librarytextfont", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.text_font, res_eval(temp_edit.text_font).display_name, action_lib_text_font)
		tab_next()
		if (res_eval(temp_edit.text_font).type = e_res_type.FONT)
		{
			tab_control_switch()
			draw_switch("librarytextaa", dx, dy, temp_edit.text_aa, action_lib_text_aa, "librarytextaatip")
			tab_next()
		}
	}
			
	// 3D / Face camera
	var sx = dx_start;
	dx_start = dx
	tab_set_collumns(true, 2)

	tab_control_checkbox()
	draw_checkbox("librarytext3d", dx, dy, temp_edit.text_3d, action_lib_text_3d)
	tab_next()
			
	tab_control_checkbox()
	draw_checkbox("librarytextfacecamera", dx, dy, temp_edit.text_face_camera, action_lib_text_face_camera)
	tab_next()

	tab_set_collumns(false)
	dx_start = sx

	// Outline
	tab_control_switch()
	draw_button_collapse("librarytextoutline", collapse_map[?"librarytextoutline"], action_lib_text_outline, temp_edit.text_outline, "librarytextoutline")
	tab_next()
	if (temp_edit.text_outline && collapse_map[?"librarytextoutline"])
	{
		tab_collapse_start()
		tab_control_color(true)
		draw_button_color("librarytextoutlinecolor", dx, dy, dw, temp_edit.text_outline_color, c_text_outline, false, action_lib_text_outline_color, true)
		tab_next()
		if (res_eval(temp_edit.text_font).type = e_res_type.FONT)
		{
			tab_control_dragger()
			draw_dragger("librarytextoutlinesize", dx, dy, dragger_width, temp_edit.text_outline_size, 0.1, 0, 8, 3, 1, tab.library.tbx_text_outline_size, action_lib_text_outline_size)
			tab_next()
		}
		tab_collapse_end()
	}

	if (setting_advanced_mode)
		draw_text_alignment("librarytext", "librarytextalignment", temp_edit.text_halign, temp_edit.text_valign, action_lib_text_halign, action_lib_text_valign)
}
