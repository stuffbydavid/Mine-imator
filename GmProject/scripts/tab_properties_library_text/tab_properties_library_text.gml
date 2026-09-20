/// tab_properties_library_text()

function tab_properties_library_text()
{
	// Font (Advanced mode only)
	if (setting_advanced_mode)
	{
		tab_control_menu()
		draw_button_menu("librarytextfont", e_menu.LIST, dx, dy, dw, 24, temp_edit.text_font, res_eval(temp_edit.text_font).display_name, action_lib_text_font)
		tab_next()
	}
			
	// 3D / Face camera
	tab_control_checkbox()
	draw_checkbox("librarytext3d", dx, dy, temp_edit.text_3d, action_lib_text_3d)
	tab_next()
			
	tab_control_checkbox()
	draw_checkbox("librarytextfacecamera", dx, dy, temp_edit.text_face_camera, action_lib_text_face_camera)
	tab_next()
}