/// tab_properties_library_block(edittab)
/// @arg edittab
/// Common template settings for blocks and scenery.

function tab_properties_library_block(edittab)
{
	if (temp_edit.type = e_temp_type.BLOCK)
	{
		var text = "";
		if (!is_undefined(mc_assets.block_name_map[?temp_edit.block_name]))
			text = minecraft_asset_get_name("block", mc_assets.block_name_map[?temp_edit.block_name].name)
			
		// Block
		tab_control(24)
		draw_label_value(dx, dy, dw - 32, 24, text_get("typeblock"), text)
			
		// Change
		if (draw_button_icon("libraryblockchange", dx + dw - 24, dy, 24, 24, object_editor.raised && obj_edit = temp_edit, icons.PENCIL, null, false, "tooltipchangeblock"))
		{
			if (obj_edit = temp_edit)
				tab_toggle(object_editor, true)
			else
			{
				obj_edit = temp_edit
				tab_show(object_editor, true)
			}
		}
			
		tab_next()
	}
	else
	{
		// Scenery
		var text;
		if (temp_edit.scenery != null)
			text = temp_edit.scenery.display_name
		else
			text = text_get("listnone")
			
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryscenery", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.scenery, text, action_lib_scenery, false, null)
		tab_next()
	}
	
	// Texture
	tab_control_menu(ui_large_height)
	draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex, res_eval(temp_edit.block_tex).display_name, action_lib_block_tex, false, res_eval(temp_edit.block_tex).block_preview_texture)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Material texture
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryblocktexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_material, res_eval(temp_edit.block_tex_material).display_name, action_lib_block_tex_material, false, res_eval(temp_edit.block_tex_material).block_preview_texture, null)
		tab_next()
				
		// Normal texture
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryblocktexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_normal, res_eval(temp_edit.block_tex_normal).display_name, action_lib_block_tex_normal, false, res_eval(temp_edit.block_tex_normal).block_preview_texture, null)
		tab_next()
	}
	
	// Randomize block states
	if (temp_edit.type = e_temp_type.BLOCK)
	{
		tab_control_checkbox()
		draw_checkbox("libraryrandomizeblocks", dx, dy, temp_edit.block_randomize, action_lib_block_randomize, "libraryrandomizeblockshelp")
		tab_next()
	}
	
	// Repeat
	tab_set_collumns(true, 2)
	tab_control_checkbox()
	draw_checkbox("libraryrepeat", dx, dy, temp_edit.block_repeat_enable, action_lib_block_repeat_enable)
	tab_next()
		
	if (temp_edit.block_repeat_enable)
	{
		tab_control_checkbox()
		draw_checkbox("librarycenter", dx, dy, temp_edit.block_center, action_lib_block_center)
		tab_next()
	}
	tab_set_collumns(false)
		
	if (temp_edit.block_repeat_enable)
	{
		axis_edit = X
		textfield_group_add("libraryrepeatx", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, X, edittab.tbx_repeat_x)
			
		axis_edit = (setting_z_is_up ? Y : Z)
		textfield_group_add("libraryrepeaty", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, edittab.tbx_repeat_y)
			
		axis_edit = (setting_z_is_up ? Z : Y)
		textfield_group_add("libraryrepeatz", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, edittab.tbx_repeat_z)
			
		tab_control_textfield_group()
		draw_textfield_group("libraryrepeat", dx, dy, dw, 0.1, 1, 1000, 1, false, true, 1)
		tab_next()
	}
}
