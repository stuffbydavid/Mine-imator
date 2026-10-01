function bench_draw_settings_text()
{
	// Text
	var labelhei = 32;
	tab_control(126 + labelhei)
	bench_settings.tbx_text.text = bench_settings.text
	draw_textfield("bench/text_text", dx, dy, dw, 126, bench_settings.tbx_text, action_bench_text, default_text, "benchtop")
	tab_next()

	content_capwid = text_caption_width("bench/text_font")

	// Font (Advanced mode only)
	if (setting_advanced_mode)
	{
		draw_button_menu("bench/text_font", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.text_font, res_eval(bench_settings.text_font).display_name, action_bench_text_font, false, null, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		if (res_eval(bench_settings.text_font).type = e_res_type.FONT)
		{
			tab_control_switch()
			draw_switch("bench/text_aa", dx, dy, bench_settings.text_aa, action_bench_text_aa, "bench/text_aa_tip")
			tab_next()
		}
	}

	// 3D/Face camera
	var sx = dx_start;
	dx_start = dx

	tab_set_columns(true, 2)

	tab_control_checkbox()
	draw_checkbox("bench/text_3d", dx, dy, bench_settings.text_3d, action_bench_text_3d)
	tab_next()

	tab_control_checkbox()
	draw_checkbox("bench/text_face_camera", dx, dy, bench_settings.text_face_camera, action_bench_text_face_camera)
	tab_next()

	tab_set_columns(false)
	dx_start = sx

	// Outline
	tab_control_switch()
	draw_switch("bench/text_outline", dx, dy, bench_settings.text_outline, action_bench_text_outline)
	tab_next()
	
	if (bench_settings.text_outline)
	{
		tab_control_color(true)
		draw_button_color("bench/text_outline_color", dx, dy, dw, bench_settings.text_outline_color, c_text_outline, false, action_bench_text_outline_color, true)
		tab_next()
		
		if (res_eval(bench_settings.text_font).type = e_res_type.FONT)
		{
			tab_control_dragger()
			draw_dragger("bench/text_outline_size", dx, dy, dragger_width, bench_settings.text_outline_size, 0.1, 0, 8, 3, 1, bench_settings.tbx_text_outline_size, action_bench_text_outline_size)
			tab_next()
		}
	}

	if (setting_advanced_mode)
		draw_text_alignment("bench/text_", "bench/text_alignment", bench_settings.text_halign, bench_settings.text_valign, action_bench_text_halign, action_bench_text_valign)
}
