/// tab_properties_library()

function tab_properties_library()
{
	// Preview selected template
	tab_control(160)
	preview_draw(tab.library.preview, dx, dy, dw, 160)
	tab_next()
	
	// List
	tab_control_sortlist(6)
	sortlist_draw(tab.library.list, dx, dy, dw, tab_control_h, temp_edit)
	tab_next()
	
	// Tools
	tab_control(24)
	
	if (draw_button_icon("librarynew", dx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "tooltiptemplatenew"))
		bench_open = true
	
	if (draw_button_icon("libraryanimate", dx + 28, dy, 24, 24, false, icons.ASSET_INSTANCE, null, temp_edit = null, "tooltiptemplateanimate"))
		action_lib_animate()
	
	if (draw_button_icon("libraryduplicate", dx + (28 * 2), dy, 24, 24, false, icons.DUPLICATE, null, temp_edit = null, "tooltiptemplateduplicate"))
		action_lib_duplicate()
	
	if (draw_button_icon("libraryremove", dx + (28 * 3), dy, 24, 24, false, icons.DELETE, null, temp_edit = null, "tooltiptemplateremove"))
		action_lib_remove()
	
	tab_next()
	
	if (temp_edit = null)
		return 0
	
	// Name
	tab_control_textfield(false)
	tab.library.tbx_name.text = temp_edit.name
	draw_textfield("libraryname", dx, dy, dw, 24, tab.library.tbx_name, action_lib_name, temp_edit.display_name, "left")
	tab_next()
	
	switch (temp_edit.type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
		{
			var text, wid;
			text = ((temp_edit.type = e_temp_type.CHARACTER) ? "librarycharmodel" : "libraryspblockmodel")
			wid = text_max_width("librarycharmodelchange") + 20
			
			// Model
			tab_control(24)
			draw_label_value(dx, dy, dw - 32, 24, text_get(text), temp_edit.model_file != null ? string(minecraft_asset_get_name("model", temp_edit.model_file.name)) : "")
			
			// Change
			if (draw_button_icon("librarycharmodelchange", dx + dw - 24, dy, 24, 24, template_editor.show, icons.PENCIL, null, false, "tooltipchangemodel"))
				tab_toggle(template_editor)
			
			tab_next()
			
			// Pattern editor
			if (temp_edit.pattern_type != "")
			{
				tab_control_button_label()
				
				if (draw_button_label("benchopeneditor", dx, dy, dw, null, e_button.SECONDARY))
					popup_pattern_editor_show(temp_edit)
				
				tab_next()
				
				if (popup = popup_pattern_editor)
					current_microani.active.value = true
			}
			
			// Skin
			var tex = null;
			with (temp_edit.model_tex)
				tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
			tab_control_menu(ui_large_height)
			draw_button_menu(((temp_edit.type = e_temp_type.SPECIAL_BLOCK) ? "libraryspblocktex" : "libraryskin"), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, temp_edit.model_tex.display_name, action_lib_model_tex, false, tex, null)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Skin (Material map)
				tex = null
				with (temp_edit.model_tex_material)
					tex = res_get_model_texture_material(model_part_get_texture_material_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
				tab_control_menu(ui_large_height)
				draw_button_menu(((temp_edit.type = e_temp_type.SPECIAL_BLOCK) ? "libraryspblocktexmaterial" : "libraryskinmaterial"), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, temp_edit.model_tex_material.display_name, action_lib_model_tex_material, false, tex, null)
				tab_next()
			
				// Skin (Normal map)
				tex = null
				with (temp_edit.model_tex_normal)
					tex = res_get_model_tex_normal(model_part_get_tex_normal_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
				tab_control_menu(ui_large_height)
				draw_button_menu(((temp_edit.type = e_temp_type.SPECIAL_BLOCK) ? "libraryspblocktexnormal" : "libraryskinnormal"), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, temp_edit.model_tex_normal.display_name, action_lib_model_tex_normal, false, tex, null)
				tab_next()
			}
			
			break
		}
		
		case e_temp_type.SCENERY:
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
			
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, false, temp_edit.block_tex.block_preview_texture, null)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Material texture
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryblocktexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_material, temp_edit.block_tex_material.display_name, action_lib_block_tex_material, false, temp_edit.block_tex_material.block_preview_texture, null)
				tab_next()
			
				// Normal texture
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryblocktexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_normal, temp_edit.block_tex_normal.display_name, action_lib_block_tex_normal, false, temp_edit.block_tex_normal.block_preview_texture, null)
				tab_next()
			}
			
			break
		}
		
		case e_temp_type.ITEM:
		{
			var wid, res;
			res = temp_edit.item_tex
			if (!res_is_ready(res))
				res = mc_res
			
			// Item image
			tab_control(24)
			
			draw_set_font(font_label)
			wid = string_width(text_get("typeitem") + ":")
			
			draw_label(text_get("typeitem") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
			
			draw_box(dx + wid + 16, dy + 4, 20, 20, false, c_level_bottom, 1)
			
			if (res.item_sheet_texture != null)
			{
				draw_texture_slot(res.item_sheet_texture, temp_edit.item_slot, dx + wid + 18, dy + 6, 16, 16, res.item_sheet_size[X], res.item_sheet_size[Y])
				
				if (draw_button_icon("libraryitemchange", dx + dw - 24, dy, 24, 24, template_editor.show, icons.PENCIL, null, false, "tooltipchangeitem"))
					tab_toggle(template_editor)
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
			draw_button_menu("libraryitemtex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex, temp_edit.item_tex.display_name, action_lib_item_tex, false, tex)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Image (Material map)
				res = temp_edit.item_tex_material
				if (!res_is_ready(res))
					res = mc_res
				
				tex = res.block_preview_texture
				if (tex = null)
					tex = res.texture
				
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryitemtexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex_material, temp_edit.item_tex_material.display_name, action_lib_item_tex_material, false, tex)
				tab_next()
				
				// Image (Normal map)
				res = temp_edit.item_tex_normal
				if (!res_is_ready(res))
					res = mc_res
				
				tex = res.block_preview_texture
				if (tex = null)
					tex = res.texture
				
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryitemtexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.item_tex_normal, temp_edit.item_tex_normal.display_name, action_lib_item_tex_normal, false, tex)
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
			
			break
		}
		
		case e_temp_type.BLOCK:
		{
			// Block
			tab_control(24)
			draw_label_value(dx, dy, dw - 32, 24, text_get("typeblock"), minecraft_asset_get_name("block", mc_assets.block_name_map[?temp_edit.block_name].name))
			
			// Change
			if (draw_button_icon("libraryblockchange", dx + dw - 24, dy, 24, 24, template_editor.show, icons.PENCIL, null, false, "tooltipchangeblock"))
				tab_toggle(template_editor)
			
			tab_next()
			
			// Texture
			tab_control_menu(ui_large_height)
			draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, false, temp_edit.block_tex.block_preview_texture)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Material texture
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryblocktexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_material, temp_edit.block_tex_material.display_name, action_lib_block_tex_material, false, temp_edit.block_tex_material.block_preview_texture, null)
				tab_next()
				
				// Normal texture
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryblocktexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.block_tex_normal, temp_edit.block_tex_normal.display_name, action_lib_block_tex_normal, false, temp_edit.block_tex_normal.block_preview_texture, null)
				tab_next()
			}
			
			break
		}
		
		case e_temp_type.BODYPART:
		{
			var text;
			
			if (temp_edit.model_file != null)
				text = text_get("librarybodypartof", minecraft_asset_get_name("modelpart", temp_edit.model_part_name), minecraft_asset_get_name("model", temp_edit.model_name))
			else
				text = text_get("librarybodypartunknown")
			
			tab_control(24)
			draw_label_value(dx, dy, dw, 24, text_get("typebodypart"), text)
			
			// Change
			if (draw_button_icon("librarybodypartchange", dx + dw - 24, dy, 24, 24, template_editor.show, icons.PENCIL))
				tab_toggle(template_editor)
			
			tab_next()
			
			// Pattern editor
			if (temp_edit.pattern_type != "")
			{
				tab_control_button_label()
				
				if (draw_button_label("benchopeneditor", dx, dy, dw, null, e_button.SECONDARY))
					popup_pattern_editor_show(temp_edit)
				
				tab_next()
			}
			
			// Skin
			var tex = null;
			with (temp_edit.model_tex)
				tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
			tab_control_menu(ui_large_height)
			draw_button_menu("librarybodypartskin", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, temp_edit.model_tex.display_name, action_lib_model_tex, false, tex)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Skin (Material map)
				tex = null
				with (temp_edit.model_tex_material)
					tex = res_get_model_texture_material(model_part_get_texture_material_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
				tab_control_menu(ui_large_height)
				draw_button_menu("librarybodypartskinmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, temp_edit.model_tex_material.display_name, action_lib_model_tex_material, false, tex, null)
				tab_next()
			
				// Skin (Normal map)
				tex = null
				with (temp_edit.model_tex_normal)
					tex = res_get_model_tex_normal(model_part_get_tex_normal_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
				tab_control_menu(ui_large_height)
				draw_button_menu("librarybodypartskinnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, temp_edit.model_tex_normal.display_name, action_lib_model_tex_normal, false, tex, null)
				tab_next()
			}
			
			break
		}
		
		case e_temp_type.PARTICLE_SPAWNER:
		{
			// Advanced mode only
			if (setting_advanced_mode)
			{
				tab_control_button_label()
			
				if (draw_button_label("libraryparticleeditoropen", dx, dy, dw, null, e_button.SECONDARY))
				{
					tab_template_editor_update_ptype_list()
					tab_toggle(template_editor)
				}
			
				if (template_editor.show)
					current_microani.active.value = true
			
				tab_next()
			}
			
			break
		}
		
		case e_temp_type.TEXT:
		{
			// Font (Advanced mode only)
			if (setting_advanced_mode)
			{
				tab_control_menu()
				draw_button_menu("librarytextfont", e_menu.LIST, dx, dy, dw, 24, temp_edit.text_font, temp_edit.text_font.display_name, action_lib_text_font)
				tab_next()
			}
			
			// 3D / Face camera
			tab_control_checkbox()
			draw_checkbox("librarytext3d", dx, dy, temp_edit.text_3d, action_lib_text_3d)
			tab_next()
			
			tab_control_checkbox()
			draw_checkbox("librarytextfacecamera", dx, dy, temp_edit.text_face_camera, action_lib_text_face_camera)
			tab_next()
			
			break
		}
		
		case e_temp_type.CUBE: 
		case e_temp_type.CONE: 
		case e_temp_type.CYLINDER: 
		case e_temp_type.SPHERE: 
		case e_temp_type.SURFACE: // Shapes
		{
			// Texture
			var text, sprite;
			sprite = null
			if (temp_edit.shape_tex != null)
			{
				text = temp_edit.shape_tex.display_name
				if (temp_edit.shape_tex.type != e_tl_type.CAMERA)
					sprite = temp_edit.shape_tex.texture
			}
			else
				text = text_get("listnone")
			
			tab_control_menu(ui_large_height)
			draw_button_menu("libraryshapetex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex, text, action_lib_shape_tex, false, sprite)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Material texture
				if (temp_edit.shape_tex_material != null)
				{
					text = temp_edit.shape_tex_material.display_name
					sprite = temp_edit.shape_tex_material.texture
				}
				else
				{
					text = text_get("listnone")
					sprite = null
				}
			
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryshapetexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex_material, text, action_lib_shape_tex_material, false, sprite)
				tab_next()
			
				// Normal texture
				if (temp_edit.shape_tex_normal != null)
				{
					text = temp_edit.shape_tex_normal.display_name
					sprite = temp_edit.shape_tex_normal.texture
				}
				else
				{
					text = text_get("listnone")
					sprite = null
				}
			
				tab_control_menu(ui_large_height)
				draw_button_menu("libraryshapetexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex_normal, text, action_lib_shape_tex_normal, false, sprite)
				tab_next()
			}
			
			// Mapped
			if (temp_edit.type = e_temp_type.CUBE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
			{
				// Advanced mode only
				if (setting_advanced_mode)
				{
					tab_control_checkbox()
					draw_checkbox("libraryshapetexmapped", dx, dy, temp_edit.shape_tex_mapped, action_lib_shape_tex_mapped, "libraryshapetexmappedtip")
					tab_next()
					
					if (temp_edit.shape_tex_mapped)
					{
						tab_control_button_label()
						
						if (draw_button_label("libraryshapetexsavemap", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
							action_lib_shape_save_map()
						
						tab_next()
					}
				}
			}
			
			if (temp_edit.shape_tex || temp_edit.shape_tex_material || temp_edit.shape_tex_normal)
			{
				if (!temp_edit.shape_tex_mapped)
				{
					// Offset
					textfield_group_add("libraryshapetexhoffset", temp_edit.shape_tex_hoffset, 0, action_lib_shape_tex_hoffset, axis_edit, tab.library.tbx_shape_tex_hoffset)
					textfield_group_add("libraryshapetexvoffset", temp_edit.shape_tex_voffset, 0, action_lib_shape_tex_voffset, axis_edit, tab.library.tbx_shape_tex_voffset)
					
					tab_control_textfield_group()
					draw_textfield_group("libraryshapetexoffset", dx, dy, dw, 1 / 100, -no_limit, no_limit, 0, true, false, 3)
					tab_next()
					
					// Repeat
					textfield_group_add("libraryshapetexhrepeat", temp_edit.shape_tex_hrepeat, 1, action_lib_shape_tex_hrepeat, axis_edit, tab.library.tbx_shape_tex_hrepeat)
					textfield_group_add("libraryshapetexvrepeat", temp_edit.shape_tex_vrepeat, 1, action_lib_shape_tex_vrepeat, axis_edit, tab.library.tbx_shape_tex_vrepeat)
					
					tab_control_textfield_group()
					draw_textfield_group("libraryshapetexrepeat", dx, dy, dw, 1 / 100, 0, no_limit, 0, true, false, 3)
					tab_next()
				}
				
				// Mirror
				tab_control_checkbox()
				draw_checkbox("libraryshapetexhmirror", dx, dy, temp_edit.shape_tex_hmirror, action_lib_shape_tex_hmirror)
				tab_next()
				
				tab_control_checkbox()
				draw_checkbox("libraryshapetexvmirror", dx, dy, temp_edit.shape_tex_vmirror, action_lib_shape_tex_vmirror)
				tab_next()
			}
			
			// Closed
			if (temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
			{
				tab_control_checkbox()
				draw_checkbox("libraryshapeclosed", dx, dy, temp_edit.shape_closed, action_lib_shape_closed)
				tab_next()
			}
			
			// Invert
			tab_control_checkbox()
			draw_checkbox("libraryshapeinvert", dx, dy, temp_edit.shape_invert, action_lib_shape_invert)
			tab_next()
			
			if (temp_edit.type = e_temp_type.SPHERE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
			{
				// Detail
				tab_control_dragger()
				draw_dragger("libraryshapedetail", dx, dy, dragger_width, temp_edit.shape_detail, 1 / 4, 3, no_limit, 32, 1, tab.library.tbx_shape_detail, action_lib_shape_detail)
				tab_next()
			}
			else if (temp_edit.type = e_temp_type.SURFACE)
			{
				// Face camera
				tab_control_checkbox()
				draw_checkbox("libraryshapefacecamera", dx, dy, temp_edit.shape_face_camera, action_lib_shape_face_camera)
				tab_next()
			}
			break
		}
		
		case e_temp_type.MODEL:
		{
			var text;
			if (temp_edit.model != null)
				text = temp_edit.model.display_name
			else
				text = text_get("listnone")
			
			// Model
			tab_control_menu()
			draw_button_menu("librarymodel", e_menu.LIST, dx, dy, dw, 24, temp_edit.model, text, action_lib_model, false, null)
			tab_next()
			
			// Texture
			var texobj, tex;
			with (temp_edit)
			{
				texobj = temp_get_model_texobj(null)
				tex = temp_get_model_tex_preview(texobj, model_file)
			}
			
			if (texobj != null)
				text = texobj.display_name
			else
				text = text_get("listnone")
			
			// Default
			if (temp_edit.model_tex = null)
				text = text_get("listdefault", text)
			
			tab_control_menu(ui_large_height)
			draw_button_menu("librarymodeltex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, text, action_lib_model_tex, false, tex)
			tab_next()
			
			if (project_render_material_maps)
			{
				// Texture (Material map)
				with (temp_edit)
				{
					texobj = temp_get_model_tex_material_obj(null)
					tex = temp_get_model_tex_material_preview(texobj, model_file)
				}
			
				if (texobj != null)
					text = texobj.display_name
				else
					text = text_get("listnone")
			
				// Default
				if (temp_edit.model_tex_material = null)
					text = text_get("listdefault", text)
			
				tab_control_menu(ui_large_height)
				draw_button_menu("librarymodeltexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, text, action_lib_model_tex_material, false, tex)
				tab_next()
			
				// Texture (Normal map)
				with (temp_edit)
				{
					texobj = temp_get_model_tex_normal_obj(null)
					tex = temp_get_model_tex_normal_preview(texobj, model_file)
				}
			
				if (texobj != null)
					text = texobj.display_name
				else
					text = text_get("listnone")
			
				// Default
				if (temp_edit.model_tex_normal = null)
					text = text_get("listdefault", text)
			
				tab_control_menu(ui_large_height)
				draw_button_menu("librarymodeltexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, text, action_lib_model_tex_normal, false, tex)
				tab_next()
			}
			
			break	
		}
	}
	
	// Randomize block states
	if (temp_edit.type = e_temp_type.BLOCK)
	{
		tab_control_checkbox()
		draw_checkbox("libraryrandomizeblocks", dx, dy, temp_edit.block_randomize, action_lib_block_randomize, "libraryrandomizeblockshelp")
		tab_next()
	}
	
	// Repeat
	if (temp_edit.type = e_temp_type.SCENERY || temp_edit.type = e_temp_type.BLOCK)
	{
		tab_control_checkbox()
		draw_checkbox("libraryrepeat", dx, dy, temp_edit.block_repeat_enable, action_lib_block_repeat_enable)
		tab_next()
		
		if (temp_edit.block_repeat_enable)
		{
			axis_edit = X
			textfield_group_add("libraryrepeatx", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, X, tab.library.tbx_repeat_x)
			
			axis_edit = (setting_z_is_up ? Y : Z)
			textfield_group_add("libraryrepeaty", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, tab.library.tbx_repeat_y)
			
			axis_edit = (setting_z_is_up ? Z : Y)
			textfield_group_add("libraryrepeatz", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, tab.library.tbx_repeat_z)
			
			tab_control_textfield_group(false)
			draw_textfield_group("libraryrepeat", dx, dy, dw, 1 / 10, 1, 1000, 1, false, true, 1)
			tab_next()
		}
	}
}
