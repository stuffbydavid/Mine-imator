function bench_draw_settings_text()
{
	// Text
	var labelhei = 32;
	tab_control(126 + labelhei)
	bench_settings.tbx_text.text = bench_settings.text
	draw_textfield("benchtexttext", dx, dy, dw, 126, bench_settings.tbx_text, action_bench_text, default_text, "benchtop")
	tab_next()

	content_capwid = text_caption_width("benchtextfont")

	// Font (Advanced mode only)
	if (setting_advanced_mode)
	{
		draw_button_menu("benchtextfont", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.text_font, res_eval(bench_settings.text_font).display_name, action_bench_text_font, false, null, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		if (res_eval(bench_settings.text_font).type = e_res_type.FONT)
		{
			tab_control_switch()
			draw_switch("benchtextaa", dx, dy, bench_settings.text_aa, action_bench_text_aa, "benchtextaatip")
			tab_next()
		}
	}

	// 3D/Face camera
	var sx = dx_start;
	dx_start = dx

	tab_set_columns(true, 2)

	tab_control_checkbox()
	draw_checkbox("benchtext3d", dx, dy, bench_settings.text_3d, action_bench_text_3d)
	tab_next()

	tab_control_checkbox()
	draw_checkbox("benchtextfacecamera", dx, dy, bench_settings.text_face_camera, action_bench_text_face_camera)
	tab_next()

	tab_set_columns(false)
	dx_start = sx

	// Outline
	tab_control_switch()
	draw_switch("benchtextoutline", dx, dy, bench_settings.text_outline, action_bench_text_outline)
	tab_next()
	
	if (bench_settings.text_outline)
	{
		tab_control_color(true)
		draw_button_color("benchtextoutlinecolor", dx, dy, dw, bench_settings.text_outline_color, c_text_outline, false, action_bench_text_outline_color, true)
		tab_next()
		
		if (res_eval(bench_settings.text_font).type = e_res_type.FONT)
		{
			tab_control_dragger()
			draw_dragger("benchtextoutlinesize", dx, dy, dragger_width, bench_settings.text_outline_size, 0.1, 0, 8, 3, 1, bench_settings.tbx_text_outline_size, action_bench_text_outline_size)
			tab_next()
		}
	}

	if (setting_advanced_mode)
		draw_text_alignment("benchtext", "benchtextalignment", bench_settings.text_halign, bench_settings.text_valign, action_bench_text_halign, action_bench_text_valign)
}
