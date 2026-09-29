function bench_draw_settings_shape()
{
	content_capwid = text_caption_width("benchshapetex", "benchshapetexmaterial", "benchshapetexnormal")
	
	tab_control(bench_list_height(bench_settings.shape_list))
	sortlist_draw(bench_settings.shape_list, dx, dy, dw, tab_control_h, bench_settings.shape_type, false, text_get("benchshapetype"))
	tab_next()

	// Texture
	var tex = null;
	content_text = text_get("listnone")
	if (bench_settings.shape_tex)
	{
		content_text = bench_settings.shape_tex.display_name
		if (bench_settings.shape_tex.type != e_tl_type.CAMERA)
			tex = bench_settings.shape_tex.texture
	}
	
	draw_button_menu("benchshapetex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex, content_text, action_bench_shape_tex, false, tex, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Material texture
		content_text = text_get("listnone")
		tex = null
		if (bench_settings.shape_tex_material)
		{
			content_text = bench_settings.shape_tex_material.display_name
			tex = bench_settings.shape_tex_material.texture
		}
		draw_button_menu("benchshapetexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex_material, content_text, action_bench_shape_tex_material, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Normal texture
		content_text = text_get("listnone")
		tex = null
		if (bench_settings.shape_tex_normal)
		{
			content_text = bench_settings.shape_tex_normal.display_name
			tex = bench_settings.shape_tex_normal.texture
		}
		draw_button_menu("benchshapetexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.shape_tex_normal, content_text, action_bench_shape_tex_normal, false, tex, null, "", null, null, content_capwid)
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
			mappedwid = 48 + string_width(text_get("benchshapetexmap"))
			draw_set_font(font_button)
			exportwid = 52 + string_width(text_get("benchshapetexsavemap"))

			if (dw >= mappedwid + exportwid + 8)
			{
				tab_control_button_label()
				draw_checkbox("benchshapetexmap", dx, dy + 4, bench_settings.shape_tex_mapped, action_bench_shape_tex_map, "benchshapetexmaptip")
				if (draw_button_label("benchshapetexsavemap", dx + dw, dy, exportwid, icons.TEXTURE_EXPORT, e_button.SECONDARY, null, e_anchor.RIGHT))
					action_lib_shape_save_map(e_temp_type.CUBE + bench_settings.shape_type)
				tab_next()
			}
			else
			{
				tab_control_checkbox()
				draw_checkbox("benchshapetexmap", dx, dy, bench_settings.shape_tex_mapped, action_bench_shape_tex_map, "benchshapetexmaptip")
				tab_next()

				tab_control_button_label()
				if (draw_button_label("benchshapetexsavemap", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
					action_lib_shape_save_map(e_temp_type.CUBE + bench_settings.shape_type)
				tab_next()
			}
		}
	}
	else if (bench_settings.shape_type = e_shape_type.SURFACE)
	{
		tab_control_checkbox()
		draw_checkbox("benchshapefacecamera", dx, dy, bench_settings.shape_face_camera, action_bench_shape_face_camera)
		tab_next()
	}
}
