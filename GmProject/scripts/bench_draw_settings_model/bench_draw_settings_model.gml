function bench_draw_settings_model()
{
	content_capwid = text_caption_width("bench/model", "bench/model_tex", "bench/model_tex_material", "bench/model_tex_normal")

	// Model
	if (bench_settings.model != null)
		content_text = bench_settings.model.display_name
	else
		content_text = text_get("list/none")

	draw_button_menu("bench/model", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model, content_text, action_bench_model, false, null, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	// Texture
	var texobj, tex;
	with (bench_settings)
	{
		if (model_file != null && !instance_exists(model_file))
			model_file = null

		texobj = temp_get_model_texobj(null)
		tex = temp_get_model_tex_preview(texobj, model_file)
	}

	if (texobj != null)
		content_text = texobj.display_name
	else
		content_text = text_get("list/none")

	// Default
	if (bench_settings.model_tex = null)
		content_text = text_get("list/default", content_text)

	draw_button_menu("bench/model_tex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex, content_text, action_bench_model_tex, false, tex, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Texture (Material map)
		with (bench_settings)
		{
			texobj = temp_get_model_tex_material_obj(null)
			tex = temp_get_model_tex_material_preview(texobj, model_file)
		}

		if (texobj != null)
			content_text = texobj.display_name
		else
			content_text = text_get("list/none")

		// Default
		if (bench_settings.model_tex_material = null)
			content_text = text_get("list/default", content_text)

		draw_button_menu("bench/model_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex_material, content_text, action_bench_model_tex_material, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Texture (Normal map)
		with (bench_settings)
		{
			texobj = temp_get_model_tex_normal_obj(null)
			tex = temp_get_model_tex_normal_preview(texobj, model_file)
		}

		if (texobj != null)
			content_text = texobj.display_name
		else
			content_text = text_get("list/none")

		// Default
		if (bench_settings.model_tex_normal = null)
			content_text = text_get("list/default", content_text)

		draw_button_menu("bench/model_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex_normal, content_text, action_bench_model_tex_normal, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}
}
