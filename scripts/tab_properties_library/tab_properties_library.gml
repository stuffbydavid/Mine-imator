/// tab_properties_library()

// Preview selected template
tab_control(160)
preview_draw(tab.library.preview, dx, dy, dw, 160)
tab_next()

// List
tab_control_sortlist(6)
sortlist_draw(tab.library.list, dx, dy, dw, tab_control_h, temp_edit)
tab_next()

// Tools
tab_control(28)

if (draw_button_icon("librarynew", dx, dy, 28, 28, false, icons.CREATE, null, false, "tooltiptemplatenew"))
	bench_open = true

if (draw_button_icon("libraryanimate", dx + 32, dy, 28, 28, false, icons.ANIMATE, null, temp_edit = null, "tooltiptemplateanimate"))
	action_lib_animate()

if (draw_button_icon("libraryduplicate", dx + (32 * 2), dy, 28, 28, false, icons.DUPLICATE, null, temp_edit = null, "tooltiptemplateduplicate"))
	action_lib_duplicate()

if (draw_button_icon("libraryremove", dx + (32 * 3), dy, 28, 28, false, icons.DELETE, null, temp_edit = null, "tooltiptemplateremove"))
	action_lib_remove()

tab_next()

if (temp_edit = null)
	return 0

// Name
tab_control(28)
tab.library.tbx_name.text = temp_edit.name
draw_textfield("libraryname", dx, dy, dw, 28, temp_edit.display_name, tab.library.tbx_name, action_lib_name, temp_edit.display_name, "left")
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
		tab_control(28)
		
		draw_set_font(font_emphasis)
		wid = string_width(text_get(text) + ":")
		
		draw_label(text_get(text) + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		
		if (temp_edit.model_file != null)
			draw_label(minecraft_asset_get_name("model", temp_edit.model_file.name), dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Change
		if (draw_button_icon("librarycharmodelchange", dx + dw - 24, dy, 28, 28, template_editor.show, icons.EDIT))
			tab_toggle(template_editor)
			
		tab_next()
		
		// Banner editor
		if (temp_edit.model_name = "banner")
		{
			tab_control(28)
			
			if (draw_button_secondary("benchopeneditor", dx, dy, dw, null))
				popup_bannereditor_show(temp_edit)
			
			tab_next()
		}
		
		// Skin
		var tex = null;
		with (temp_edit.model_tex)
			tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
		
		tab_control_menu(36)
		draw_button_menu(((temp_edit.type = e_temp_type.SPECIAL_BLOCK) ? "libraryspblocktex" : "libraryskin"), e_menu.LIST, dx, dy, dw, 36, temp_edit.model_tex, temp_edit.model_tex.display_name, action_lib_model_tex, false, tex, null)
		tab_next()
		
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
		
		tab_control_menu(28)
		draw_button_menu("libraryscenery", e_menu.LIST, dx, dy, dw, 32, temp_edit.scenery, text, action_lib_scenery, false, null)
		tab_next()
		
		// Texture
		tab_control_menu(36)
		draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, 36, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, false, temp_edit.block_tex.block_preview_texture, null)
		tab_next()
		
		break
	}
	
	case e_temp_type.ITEM:
	{
		var wid, res;
		res = temp_edit.item_tex
		if (!res.ready)
			res = mc_res
		
		// Item image
		tab_control(28)
		
		draw_set_font(font_emphasis)
		wid = string_width(text_get("typeitem") + ":")
		
		draw_label(text_get("typeitem") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		
		draw_box(dx + wid + 16, dy + 4, 20, 20, false, c_background_secondary, 1)
		
		if (res.item_sheet_texture != null)
		{
			draw_texture_slot(res.item_sheet_texture, temp_edit.item_slot, dx + wid + 18, dy + 6, 16, 16, res.item_sheet_size[X], res.item_sheet_size[Y])
			
			if (draw_button_icon("libraryitemchange", dx + dw - 24, dy, 28, 28, template_editor.show, icons.EDIT, null, false, "tooltipchangeitem"))
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
		
		tab_control_menu(36)
		draw_button_menu("libraryitemtex", e_menu.LIST, dx, dy, dw, 36, temp_edit.item_tex, temp_edit.item_tex.display_name, action_lib_item_tex, false, tex)
		tab_next()
		
		// Graphics
		tab_control_switch()
		draw_switch("libraryitem3d", dx, dy, temp_edit.item_3d, action_lib_item_3d, true)
		tab_next()
		
		tab_control_switch()
		draw_switch("libraryitemfacecamera", dx, dy, temp_edit.item_face_camera, action_lib_item_face_camera, false)
		tab_next()
		
		tab_control_switch()
		draw_switch("libraryitembounce", dx, dy, temp_edit.item_bounce, action_lib_item_bounce, false)
		tab_next()
		
		tab_control_switch()
		draw_switch("libraryitemspin", dx, dy, temp_edit.item_spin, action_lib_item_spin, false)
		tab_next()

		break
	}
	
	case e_temp_type.BLOCK:
	{
		// Block
		tab_control(28)
		
		draw_set_font(font_emphasis)
		wid = string_width(text_get("typeblock") + ":")
		
		draw_label(text_get("typeblock") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		draw_label(minecraft_asset_get_name("block", mc_assets.block_name_map[?temp_edit.block_name].name), dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Change
		if (draw_button_icon("libraryblockchange", dx + dw - 24, dy, 28, 28, template_editor.show, icons.EDIT))
			tab_toggle(template_editor)
			
		tab_next()
		
		// Texture
		tab_control_menu(36)
		draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, 36, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, false, temp_edit.block_tex.block_preview_texture)
		tab_next()
		
		break
	}
	
	case e_temp_type.BODYPART:
	{
		tab_control(28)
		
		draw_set_font(font_emphasis)
		var wid = string_width(text_get("typebodypart") + ":");
		
		draw_label(text_get("typebodypart") + ":", dx, dy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		
		var text;
		
		if (temp_edit.model_file != null)
			text = text_get("librarybodypartof", minecraft_asset_get_name("modelpart", temp_edit.model_part_name), minecraft_asset_get_name("model", temp_edit.model_name))
		else
			text = text_get("librarybodypartunknown")
		
		draw_label(text, dx + wid + 8, dy + 14, fa_left, fa_middle, c_text_main, a_text_main, font_value)
		
		// Change
		if (draw_button_icon("librarybodypartchange", dx + dw - 24, dy, 28, 28, template_editor.show, icons.EDIT))
			tab_toggle(template_editor)
			
		tab_next()
		
		// Banner editor
		if (temp_edit.model_name = "banner")
		{
			tab_control(28)
			
			if (draw_button_secondary("benchopeneditor", dx, dy, dw, null))
				popup_bannereditor_show(temp_edit)
			
			tab_next()
		}
		
		// Skin
		var tex = null;
		with (temp_edit.model_tex)
			tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
		
		tab_control_menu(36)
		draw_button_menu("librarybodypartskin", e_menu.LIST, dx, dy, dw, 36, temp_edit.model_tex, temp_edit.model_tex.display_name, action_lib_model_tex, false, tex)
		tab_next()
		
		break
	}
	
	case e_temp_type.PARTICLE_SPAWNER:
	{
		tab_control(28)
		
		if (draw_button_secondary("libraryparticleeditoropen", dx, dy, dw, null))
		{
			tab_template_editor_update_ptype_list()
			tab_toggle(template_editor)
		}
		
		if (template_editor.show)
			current_mcroani.holding = true
		
		tab_next()
		
		break
	}
	
	case e_temp_type.TEXT:
	{
		// Font
		tab_control_menu(28)
		draw_button_menu("librarytextfont", e_menu.LIST, dx, dy, dw, 28, temp_edit.text_font, temp_edit.text_font.display_name, action_lib_text_font)
		tab_next()
		
		// 3D / Face camera
		tab_control_switch()
		draw_switch("librarytext3d", dx, dy, temp_edit.text_3d, action_lib_text_3d, false)
		tab_next()
		
		tab_control_switch()
		draw_switch("librarytextfacecamera", dx, dy, temp_edit.text_face_camera, action_lib_text_face_camera, false)
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
		
		tab_control_menu(36)
		draw_button_menu("libraryshapetex", e_menu.LIST, dx, dy, dw, 36, temp_edit.shape_tex, text, action_lib_shape_tex, false, sprite)
		tab_next()
		
		// Mapped
		if (temp_edit.type = e_temp_type.CUBE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
		{
			tab_control_switch()
			draw_switch("libraryshapetexmapped", dx, dy, temp_edit.shape_tex_mapped, action_lib_shape_tex_mapped, false)
			tab_next()
			
			if (temp_edit.shape_tex_mapped)
			{
				tab_control(36)
				
				if (draw_button_secondary("libraryshapetexsavemap", dx, dy, dw, null, icons.TEXTURE_EXPORT))
					action_lib_shape_save_map()
				
				tab_next()
			}
			
		}
		
		if (temp_edit.shape_tex)
		{
			if (!temp_edit.shape_tex_mapped)
			{
				// Offset
				tab_control(48)
				textfield_group_add("libraryshapetexhoffset", temp_edit.shape_tex_hoffset, 0, action_lib_shape_tex_hoffset, axis_edit, tab.library.tbx_shape_tex_hoffset)
				textfield_group_add("libraryshapetexvoffset", temp_edit.shape_tex_voffset, 0, action_lib_shape_tex_voffset, axis_edit, tab.library.tbx_shape_tex_voffset)
				draw_textfield_group("libraryshapetexoffset", dx, dy, dw, 1 / 100, -no_limit, no_limit, 0, true)
				tab_next()
				
				// Repeat
				tab_control(48)
				textfield_group_add("libraryshapetexhrepeat", temp_edit.shape_tex_hrepeat, 0, action_lib_shape_tex_hrepeat, axis_edit, tab.library.tbx_shape_tex_hrepeat)
				textfield_group_add("libraryshapetexvrepeat", temp_edit.shape_tex_vrepeat, 0, action_lib_shape_tex_vrepeat, axis_edit, tab.library.tbx_shape_tex_vrepeat)
				draw_textfield_group("libraryshapetexrepeat", dx, dy, dw, 1 / 100, 0, no_limit, 0, true)
				tab_next()
			}
			
			// Mirror
			tab_control_switch()
			draw_switch("libraryshapetexhmirror", dx, dy, temp_edit.shape_tex_hmirror, action_lib_shape_tex_hmirror, false)
			tab_next()
			
			tab_control_switch()
			draw_switch("libraryshapetexvmirror", dx, dy, temp_edit.shape_tex_vmirror, action_lib_shape_tex_vmirror, false)
			tab_next()
		}
		
		// Closed
		if (temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
		{
			tab_control_switch()
			draw_switch("libraryshapeclosed", dx, dy, temp_edit.shape_closed, action_lib_shape_closed, true)
			tab_next()
		}
		
		// Invert
		tab_control_switch()
		draw_switch("libraryshapeinvert", dx, dy, temp_edit.shape_invert, action_lib_shape_invert, false)
		tab_next()
		
		if (temp_edit.type = e_temp_type.SPHERE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
		{
			// Detail
			tab_control_inputbox()
			draw_dragger("libraryshapedetail", dx, dy, 86, temp_edit.shape_detail, 1 / 4, 4, no_limit, 32, 1, tab.library.tbx_shape_detail, action_lib_shape_detail)
			tab_next()
		}
		else if (temp_edit.type = e_temp_type.SURFACE)
		{
			// Face camera
			tab_control_switch()
			draw_switch("libraryshapefacecamera", dx, dy, temp_edit.shape_face_camera, action_lib_shape_face_camera, false)
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
		tab_control_menu(28)
		draw_button_menu("librarymodel", e_menu.LIST, dx, dy, dw, 28, temp_edit.model, text, action_lib_model, false, null)
		tab_next()
		
		// Texture
		var texobj, tex, text;
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
		
		tab_control_menu(36)
		draw_button_menu("librarymodeltex", e_menu.LIST, dx, dy, dw, 36, temp_edit.model_tex, text, action_lib_model_tex, false, tex)
		tab_next()
		break	
	}
}

// Repeat
if (temp_edit.type = e_temp_type.SCENERY || temp_edit.type = e_temp_type.BLOCK)
{
	tab_control_switch()
	draw_switch("libraryrepeat", dx, dy, temp_edit.block_repeat_enable, action_lib_block_repeat_enable, false)
	tab_next()
	
	if (temp_edit.block_repeat_enable)
	{
		axis_edit = X
		textfield_group_add("libraryrepeatx", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, X, tab.library.tbx_repeat_x)
		
		axis_edit = (setting_z_is_up ? Y : Z)
		textfield_group_add("libraryrepeaty", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, tab.library.tbx_repeat_y)
		
		axis_edit = (setting_z_is_up ? Z : Y)
		textfield_group_add("libraryrepeatz", temp_edit.block_repeat[axis_edit], 1, action_lib_block_repeat, axis_edit, tab.library.tbx_repeat_z)
		
		tab_control_inputbox()
		draw_textfield_group("libraryrepeat", dx, dy, dw, 1 / 10, 1, 1000, 1)
		tab_next()
	}
}
