function bench_draw_settings_shape()
{
	content_capwid = text_caption_width("bench/shape_tex", "bench/shape_tex_material", "bench/shape_tex_normal")
	
	tab_control(bench_list_height(bench_settings.shape_list))
	sortlist_draw(bench_settings.shape_list, dx, dy, dw, tab_control_h, bench_settings.shape_type, false, text_get("bench/shape_type"))
	tab_next()

	// Texture
	var tex = null;
	content_text = text_get("list/none")
	if (bench_settings.shape_tex)
	{
		content_text = bench_settings.shape_tex.display_name
		if (bench_settings.shape_tex.type != e_tl_type.CAMERA)
			tex = bench_settings.shape_tex.texture
	}
	
	draw_button_menu("bench/shape_tex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex, content_text, action_bench_shape_tex, false, tex, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Material texture
		content_text = text_get("list/none")
		tex = null
		if (bench_settings.shape_tex_material)
		{
			content_text = bench_settings.shape_tex_material.display_name
			tex = bench_settings.shape_tex_material.texture
		}
		draw_button_menu("bench/shape_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex_material, content_text, action_bench_shape_tex_material, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Normal texture
		content_text = text_get("list/none")
		tex = null
		if (bench_settings.shape_tex_normal)
		{
			content_text = bench_settings.shape_tex_normal.display_name
			tex = bench_settings.shape_tex_normal.texture
		}
		draw_button_menu("bench/shape_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex_normal, content_text, action_bench_shape_tex_normal, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}

	// Is mapped
	if (bench_settings.shape_type = e_shape_type.CUBE || 
		bench_settings.shape_type = e_shape_type.CYLINDER || 
		bench_settings.shape_type = e_shape_type.CONE)
	{
		// Advanced mode only
		if (setting_advanced_mode)
		{
			var mappedwid, exportwid;
			draw_set_font(font_label)
			mappedwid = 48 + string_width(text_get("bench/shape_tex_map"))
			draw_set_font(font_button)
			exportwid = 52 + string_width(text_get("bench/shape_tex_save_map"))

			if (dw >= mappedwid + exportwid + 8)
			{
				tab_control_button_label()
				draw_checkbox("bench/shape_tex_map", dx, dy + 4, bench_settings.shape_tex_mapped, action_bench_shape_tex_map, "bench/shape_tex_map_tip")
				if (draw_button_label("bench/shape_tex_save_map", dx + dw, dy, exportwid, icons.TEXTURE_EXPORT, e_button.SECONDARY, null, e_anchor.RIGHT))
					action_lib_shape_save_map(e_temp_type.CUBE + bench_settings.shape_type)
				tab_next()
			}
			else
			{
				tab_control_checkbox()
				draw_checkbox("bench/shape_tex_map", dx, dy, bench_settings.shape_tex_mapped, action_bench_shape_tex_map, "bench/shape_tex_map_tip")
				tab_next()

				tab_control_button_label()
				if (draw_button_label("bench/shape_tex_save_map", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
					action_lib_shape_save_map(e_temp_type.CUBE + bench_settings.shape_type)
				tab_next()
			}
		}
	}
	else if (bench_settings.shape_type = e_shape_type.SURFACE)
	{
		tab_control_checkbox()
		draw_checkbox("bench/shape_face_camera", dx, dy, bench_settings.shape_face_camera, action_bench_shape_face_camera)
		tab_next()
	}
}
