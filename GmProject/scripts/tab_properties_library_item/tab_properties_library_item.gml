/// tab_properties_library_item()

function tab_properties_library_item()
{
	var wid, res;
	res = res_eval(temp_edit.item_tex)
			
	// Item image
	tab_control(24)
			
	draw_set_font(font_label)
	wid = string_width(text_get("typeitem") + ":")
			
	draw_label(text_get("typeitem") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
			
	draw_box(dx + wid + 16, dy + 4, 20, 20, false, c_level_bottom, 1)
			
	if (res.item_sheet_texture[e_item_sheet.SIZE16] != null)
	{
		var sheet, slot;
		if (res.type = e_res_type.PACK)
		{
			var decodedslot = minecraft_assets_texture_picker_slot_decode(temp_edit.item_slot, mc_assets.item_texture_list)
			sheet = decodedslot[0]
			slot = decodedslot[1]
		}
		else
		{
			sheet = e_item_sheet.SIZE16
			slot = temp_edit.item_slot
		}
				
		if (sheet >= 0)
		{
			draw_texture_slot(res.item_sheet_texture[sheet], slot, dx + wid + 18, dy + 6, 16, 16, res.type = e_res_type.PACK ? minecraft_item_sheet_size[sheet][X] : res.item_sheet_size[X], res.type = e_res_type.PACK ? minecraft_item_sheet_size[sheet][Y] : res.item_sheet_size[Y])
			if (slot >= 0 && slot < ds_list_size(mc_assets.item_texture_list[sheet]))
				tip_set(minecraft_texture_get_name(mc_assets.item_texture_list[sheet][|slot]), dx + wid + 16, dy + 4, 20, 20)
		}
				
		if (draw_button_icon("libraryitemchange", dx + dw - 24, dy, 24, 24, object_editor.show && obj_edit = temp_edit, icons.PENCIL, null, false, "tooltipchangeitem"))
		{
			if (obj_edit = temp_edit)
				tab_toggle(object_editor)
			else
			{
				obj_edit = temp_edit
				tab_show(object_editor, true)
			}
		}
	}
	else
	{
		var scale = min(16 / texture_width(res.texture), 16 / texture_height(res.texture));
		draw_texture(res.texture, dx + wid + 18, dy + 6, scale, scale)
	}
			
	tab_next()
			
	// Image
	var tex = res.block_preview_texture;
	if (tex = null)
		tex = res.texture
			
	tab_control_menu(ui_large_height)
	draw_button_menu("libraryitemtex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex, res_eval(temp_edit.item_tex).display_name, action_lib_item_tex, false, tex)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Image (Material map)
		res = res_eval(temp_edit.item_tex_material)
		tex = res.block_preview_texture
		if (tex = null)
			tex = res.texture
				
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryitemtexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex_material, res_eval(temp_edit.item_tex_material).display_name, action_lib_item_tex_material, false, tex)
		tab_next()
				
		// Image (Normal map)
		res = res_eval(temp_edit.item_tex_normal)
		tex = res.block_preview_texture
		if (tex = null)
			tex = res.texture
				
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryitemtexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex_normal, res_eval(temp_edit.item_tex_normal).display_name, action_lib_item_tex_normal, false, tex)
		tab_next()
	}
			
	var sx;
	sx = dx_start
			
	dx_start = dx
	tab_set_collumns(true, 2)
			
	// Graphics
	tab_control_checkbox()
	draw_checkbox("libraryitem3d", dx, dy, temp_edit.item_3d, action_lib_item_3d)
	tab_next()
			
	tab_control_checkbox()
	draw_checkbox("libraryitemfacecamera", dx, dy, temp_edit.item_face_camera, action_lib_item_face_camera)
	tab_next()
			
	tab_control_checkbox()
	draw_checkbox("libraryitembounce", dx, dy, temp_edit.item_bounce, action_lib_item_bounce)
	tab_next()
			
	tab_control_checkbox()
	draw_checkbox("libraryitemspin", dx, dy, temp_edit.item_spin, action_lib_item_spin)
	tab_next()
			
	tab_set_collumns(false)
	dx_start = sx
}
