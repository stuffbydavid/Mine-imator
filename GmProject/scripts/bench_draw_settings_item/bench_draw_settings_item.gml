function bench_draw_settings_item()
{
	var res = res_eval(bench_settings.item_tex);
	draw_label(text_get("type/item") + ":", dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)

	content_capwid = text_caption_width("type/item")
	
	if (res.item_sheet_texture[e_item_sheet.SIZE16] != null)
	{
		var sheet, slot;
		if (res.type = e_res_type.PACK)
		{
			var decodedslot = minecraft_assets_texture_picker_slot_decode(bench_settings.item_slot, mc_assets.item_texture_list);
			sheet = decodedslot[0]
			slot = decodedslot[1]
		}
		else
		{
			sheet = e_item_sheet.SIZE16
			slot = bench_settings.item_slot
		}
		
		if (sheet >= 0)
		{
			draw_texture_slot(res.item_sheet_texture[sheet], slot, dx + content_capwid, dy + 4, 16, 16, res.type = e_res_type.PACK ? minecraft_item_sheet_size[sheet][X] : res.item_sheet_size[X], res.type = e_res_type.PACK ? minecraft_item_sheet_size[sheet][Y] : res.item_sheet_size[Y])
			if (slot >= 0 && slot < ds_list_size(mc_assets.item_texture_list[sheet]))
				tip_set(minecraft_texture_get_name(mc_assets.item_texture_list[sheet][|slot]), dx + content_capwid, dy + 4, 16, 16)
		}
	}
	else
	{
		var scale = min(16 / texture_width(res.texture), 16 / texture_height(res.texture));
		draw_texture(res.texture, dx + content_capwid, dy + 4, scale, scale)
	}
	
	// Item select
	if (res.item_sheet_texture[e_item_sheet.SIZE16] != null)
	{
		var textures, slots, sheetsizes;
		if (res.type = e_res_type.PACK)
		{
			textures = res.item_sheet_texture
			sheetsizes = minecraft_item_sheet_size
			slots = array_create(e_item_sheet.amount)
			for (var sheet = 0; sheet < e_item_sheet.amount; sheet++)
				slots[sheet] = ds_list_size(mc_assets.item_texture_list[sheet])
		}
		else
		{
			textures = [ res.item_sheet_texture[e_item_sheet.SIZE16] ]
			sheetsizes = [ res.item_sheet_size ]
			slots = [ res.item_sheet_size[X] * res.item_sheet_size[Y] ]
		}
		
		var listh, minimum, fixed, availableheight, referenceheight;
		minimum = list_minimum_items * ui_small_height
		fixed = bench_settings.height_fixed[bench_tab]
		availableheight = max(0, bench_settings.height - fixed)
		referenceheight = max(0, bench_settings.height - bench_settings.height_fixed_base[bench_tab])
		listh = fixed > 0 ? min(availableheight, max(minimum, referenceheight)) : minimum
		
		bench_settings.list_height = listh
		bench_settings.list_minimum_height = minimum
		
		draw_texture_picker(bench_settings.item_slot, textures, slots, sheetsizes, dx, dy, dw, listh, bench_settings.item_scroll, action_bench_item_slot, mc_assets.item_texture_list, null, action_bench_create)
		dy += listh + 8
	}
	else
		dy += 32

	// Settings
	var sx = dx_start;

	dx_start = dx
	tab_set_columns(true, 2)

	tab_control_checkbox()
	draw_checkbox("bench/item_3d", dx, dy, bench_settings.item_3d, action_bench_item_3d)
	tab_next()

	tab_control_checkbox()
	draw_checkbox("bench/item_face_camera", dx, dy, bench_settings.item_face_camera, action_bench_item_face_camera)
	tab_next()

	tab_control_checkbox()
	draw_checkbox("bench/item_bounce", dx, dy, bench_settings.item_bounce, action_bench_item_bounce)
	tab_next()

	tab_control_checkbox()
	draw_checkbox("bench/item_spin", dx, dy, bench_settings.item_spin, action_bench_item_spin)
	tab_next()

	tab_set_columns(false)
	dx_start = sx

	// Image
	var tex = res.block_preview_texture;
	if (tex = null)
		tex = res.texture

	content_capwid = text_caption_width("bench/item_tex", "bench/item_tex_material", "bench/item_tex_normal")
	draw_button_menu("bench/item_tex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.item_tex, res_eval(bench_settings.item_tex).display_name, action_bench_item_tex, false, res_eval(bench_settings.item_tex).block_preview_texture, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Image (Material map)
		tex = res.block_preview_texture
		if (tex = null)
			tex = res.texture

		draw_button_menu("bench/item_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.item_tex_material, res_eval(bench_settings.item_tex_material).display_name, action_bench_item_tex_material, false, res_eval(bench_settings.item_tex_material).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Image (Normal map)
		tex = res.block_preview_texture
		if (tex = null)
			tex = res.texture

		draw_button_menu("bench/item_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.item_tex_normal, res_eval(bench_settings.item_tex_normal).display_name, action_bench_item_tex_normal, false, res_eval(bench_settings.item_tex_normal).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}
	dy += 4

	window_scroll_focus = string(bench_settings.item_scroll)
}
