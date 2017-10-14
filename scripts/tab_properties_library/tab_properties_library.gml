/// tab_properties_library()

// Preview selected template
tab_control(160)
preview_draw(tab.library.preview, dx + floor(dw / 2) - 80, dy, 160)
tab_next()

// List
var listh = 256;
if (content_direction = e_scroll.HORIZONTAL)
	listh = max(130, dh - (dy - dy_start) - 30)

if (tab_control(listh))
{
	listh = dh - (dy - dy_start - 18) - 30
	tab_control_h = listh
}
sortlist_draw(tab.library.list, dx, dy, dw, listh, temp_edit)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("librarynew", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.CREATE))
	bench_open = true
	
if (draw_button_normal("libraryanimate", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, (temp_edit != null), icons.ANIMATE))
	action_lib_animate()
	
if (draw_button_normal("libraryremove", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, (temp_edit != null), icons.REMOVE))
	action_lib_remove()
	
if (draw_button_normal("libraryduplicate", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, (temp_edit != null), icons.DUPLICATE))
	action_lib_duplicate()
	
tab_next()

if (!temp_edit)
	return 0
	
var capwid = text_caption_width("libraryname", "librarycharmodel", "libraryskin", 
								"typescenery", "libraryblocktex", 
								"typeitem", "libraryitemtex", 
								"libraryspblockmodel", "libraryspblocktex", 
								"typeblock", 
								"typebodypart", "librarybodypartskin", 
								"librarytextfont", 
								"libraryshapetex");
	
// Name
tab_control_inputbox()
tab.library.tbx_name.text = temp_edit.name
draw_inputbox("libraryname", dx, dy, dw, temp_edit.display_name, tab.library.tbx_name, action_lib_name, capwid)
tab_next()

switch (temp_edit.type)
{
	case e_temp_type.CHARACTER:
	case e_temp_type.SPECIAL_BLOCK:
	{
		var text, wid;
		text = test(temp_edit.type = e_temp_type.CHARACTER, "librarycharmodel", "libraryspblockmodel")
		wid = text_max_width("librarycharmodelchange") + 20
		
		// Model
		tab_control(24)
		draw_label(text_get(text) + ":", dx, dy + 12, fa_left, fa_middle)
		if (temp_edit.model_file != null)
			draw_label(minecraft_asset_get_name("model", temp_edit.model_file.name), dx + capwid, dy + 12, fa_left, fa_middle)
		
		// Change
		if (draw_button_normal("librarycharmodelchange", dx + dw - wid, dy, wid, 24, e_button.TEXT, template_editor.show, true, true))
			tab_toggle(template_editor)
		tab_next()
		
		// Skin
		var tex = null;
		with (temp_edit.skin)
			tex = res_get_model_texture(model_part_texture_name(temp_edit.model_texture_name_map, temp_edit.model_file))
		
		tab_control(40)
		draw_button_menu(test(temp_edit.type = e_temp_type.SPECIAL_BLOCK, "libraryspblocktex", "libraryskin"), e_menu.LIST, dx, dy, dw, 40, temp_edit.skin, temp_edit.skin.display_name, action_lib_skin, tex, null, capwid)
		tab_next()
		
		break
	}
	
	case e_temp_type.SCENERY:
	{
		// Schematic
		var text;
		if (temp_edit.scenery != null)
			text = temp_edit.scenery.display_name
		else
			text = text_get("listnone")
		tab_control(32)
		draw_button_menu("libraryscenery", e_menu.LIST, dx, dy, dw, 32, temp_edit.scenery, text, action_lib_scenery, null, null, capwid)
		tab_next()
		
		// Texture
		tab_control(40)
		draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, 40, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, temp_edit.block_tex.block_preview_texture, null, capwid)
		tab_next()
		
		break
	}
	
	case e_temp_type.ITEM:
	{
		var wid, res;
		wid = text_max_width("libraryitemchange") + 20
		res = temp_edit.item_tex
		if (!res.ready)
			res = mc_res
		
		// Item image
		tab_control(24)
		draw_label(text_get("typeitem") + ":", dx, dy + 12, fa_left, fa_middle)
		if (res.item_sheet_texture != null)
		{
			draw_texture_slot(res.item_sheet_texture, temp_edit.item_slot, dx + capwid, dy + 4, 16, 16, res.item_sheet_size[X], res.item_sheet_size[Y])
			if (draw_button_normal("libraryitemchange", dx + dw - wid, dy, wid, 24, e_button.TEXT, template_editor.show, true, true))
				tab_toggle(template_editor)
		}
		else
		{
			var scale = min(16 / texture_width(res.texture), 16 / texture_height(res.texture));
			draw_texture(res.texture, dx + capwid, dy + 2, scale, scale)
		}
		tab_next()
		
		// Image
		tab_control(40)
		draw_button_menu("libraryitemtex", e_menu.LIST, dx, dy, dw, 40, temp_edit.item_tex, temp_edit.item_tex.display_name, action_lib_item_tex, temp_edit.item_tex.block_preview_texture, null, capwid)
		tab_next()
		
		// Graphics
		tab_control_checkbox()
		draw_checkbox("libraryitem3d", dx, dy, temp_edit.item_3d, action_lib_item_3d)
		draw_checkbox("libraryitemfacecamera", dx + floor(dw * 0.3), dy, temp_edit.item_face_camera, action_lib_item_face_camera)
		draw_checkbox("libraryitembounce", dx + floor(dw * 0.7), dy, temp_edit.item_bounce, action_lib_item_bounce)
		tab_next()
		
		break
	}
	
	case e_temp_type.BLOCK:
	{
		// Block
		var wid = text_max_width("libraryblockchange") + 20;
		tab_control(24)
		draw_label(text_get("typeblock") + ":", dx, dy + 12, fa_left, fa_middle)
		draw_label(minecraft_asset_get_name("block", mc_assets.block_name_map[?temp_edit.block_name].name), dx + capwid, dy + 12, fa_left, fa_middle)
		if (draw_button_normal("libraryblockchange", dx + dw - wid, dy, wid, 24, e_button.TEXT, template_editor.show, true, true))
			tab_toggle(template_editor)
		tab_next()
		
		// Texture
		tab_control(40)
		draw_button_menu("libraryblocktex", e_menu.LIST, dx, dy, dw, 40, temp_edit.block_tex, temp_edit.block_tex.display_name, action_lib_block_tex, temp_edit.block_tex.block_preview_texture, null, capwid)
		tab_next()
		
		break
	}
	
	case e_temp_type.BODYPART:
	{
		// Model
		tab_control(24)
		draw_label(text_get("typebodypart") + ":", dx, dy + 12, fa_left, fa_middle)
		
		if (temp_edit.model_part != null)
			draw_label(text_get("librarybodypartof", minecraft_asset_get_name("modelpart", temp_edit.model_part_name), minecraft_asset_get_name("model", temp_edit.model_name)), dx + capwid, dy + 12, fa_left, fa_middle)
		else
			draw_label(text_get("librarybodypartunknown"), dx + capwid, dy + 12, fa_left, fa_middle)
		
		// Change
		var wid = text_max_width("librarybodypartchange") + 20;
		if (draw_button_normal("librarybodypartchange", dx + dw - wid, dy, wid, 24, e_button.TEXT, template_editor.show, true, true))
			tab_toggle(template_editor)
		tab_next()
		
		// Skin
		var tex = null;
		with (temp_edit.skin)
			tex = res_get_model_texture(model_part_texture_name(temp_edit.model_texture_name_map, temp_edit.model_file))
				
		tab_control(40)
		draw_button_menu("librarybodypartskin", e_menu.LIST, dx, dy, dw, 40, temp_edit.skin, temp_edit.skin.display_name, action_lib_skin, tex, null, capwid)
		tab_next()
		
		break
	}
	
	case e_temp_type.PARTICLE_SPAWNER:
	{
		// Open editor
		var wid = text_max_width("libraryparticleeditoropen") + 20;
		tab_control(24)
		if (draw_button_normal("libraryparticleeditoropen", dx + floor(dw / 2 - wid / 2), dy, wid, 24, e_button.TEXT, template_editor.show, true, true))
		{
			tab_template_editor_update_ptype_list()
			tab_toggle(template_editor)
		}
		tab_next()
		break
	}
	
	case e_temp_type.TEXT:
	{
		// Font
		tab_control(32)
		draw_button_menu("librarytextfont", e_menu.LIST, dx, dy, dw, 32, temp_edit.text_font, temp_edit.text_font.display_name, action_lib_text_font, null, null, capwid)
		tab_next()
		
		// 3D / Face camera
		tab_control_checkbox()
		draw_checkbox("librarytext3d", dx, dy, temp_edit.text_3d, action_lib_text_3d)
		draw_checkbox("librarytextfacecamera", dx + floor(dw / 4), dy, temp_edit.text_face_camera, action_lib_text_face_camera)
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
		
		tab_control(40)
		draw_button_menu("libraryshapetex", e_menu.LIST, dx, dy, dw, 40, temp_edit.shape_tex, text, action_lib_shape_tex, sprite, null, capwid)
		tab_next()
		
		// Mapped
		if (temp_edit.type = e_temp_type.CUBE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
		{
			tab_control(24)
			draw_checkbox("libraryshapetexmapped", dx, dy + 3, temp_edit.shape_tex_mapped, action_lib_shape_tex_mapped)
			
			if (temp_edit.shape_tex_mapped)
			{
				var wid = text_max_width("libraryshapetexsavemap") + 10;
				if (draw_button_normal("libraryshapetexsavemap", dx + dw - wid, dy, wid, 24))
					action_lib_shape_save_map()
			}
			tab_next()
		}
		
		if (temp_edit.shape_tex)
		{
			capwid = text_caption_width("libraryshapetexhoffset", "libraryshapetexvoffset", "libraryshapetexhrepeat", "libraryshapetexvrepeat")
			
			if (!temp_edit.shape_tex_mapped)
			{
				// Offset
				tab_control_dragger()
				draw_dragger("libraryshapetexhoffset", dx, dy, dw, temp_edit.shape_tex_hoffset, 1 / 100, -no_limit, no_limit, 0, 0, tab.library.tbx_shape_tex_hoffset, action_lib_shape_tex_hoffset, capwid)
				tab_next()
				
				tab_control_dragger()
				draw_dragger("libraryshapetexvoffset", dx, dy, dw, temp_edit.shape_tex_voffset, 1 / 100, -no_limit, no_limit, 0, 0, tab.library.tbx_shape_tex_voffset, action_lib_shape_tex_voffset, capwid)
				tab_next()
				
				// Repeat
				tab_control_dragger()
				draw_dragger("libraryshapetexhrepeat", dx, dy, dw, temp_edit.shape_tex_hrepeat, temp_edit.shape_tex_hrepeat / 100, 0, no_limit, 1, 0, tab.library.tbx_shape_tex_hrepeat, action_lib_shape_tex_hrepeat, capwid)
				tab_next()
				
				tab_control_dragger()
				draw_dragger("libraryshapetexvrepeat", dx, dy, dw, temp_edit.shape_tex_vrepeat, temp_edit.shape_tex_vrepeat / 100, 0, no_limit, 1, 0, tab.library.tbx_shape_tex_vrepeat, action_lib_shape_tex_vrepeat, capwid)
				tab_next()
			}
			
			// Mirror
			tab_control_checkbox()
			draw_checkbox("libraryshapetexhmirror", dx, dy, temp_edit.shape_tex_hmirror, action_lib_shape_tex_hmirror)
			draw_checkbox("libraryshapetexvmirror", dx + floor(dw * 0.5), dy, temp_edit.shape_tex_vmirror, action_lib_shape_tex_vmirror)
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
			draw_dragger("libraryshapedetail", dx, dy, dw, temp_edit.shape_detail, 1 / 4, 4, no_limit, 32, 1, tab.library.tbx_shape_detail, action_lib_shape_detail)
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
}

// Repeat
if (temp_edit.type = e_temp_type.SCENERY || temp_edit.type = e_temp_type.BLOCK)
{
	tab_control_checkbox()
	draw_checkbox("libraryrepeat", dx, dy, temp_edit.block_repeat_enable, action_lib_block_repeat_enable)
	tab_next()
	
	if (temp_edit.block_repeat_enable)
	{
		capwid = text_caption_width("libraryrepeatx", "libraryrepeaty", "libraryrepeatz")
		
		axis_edit = X
		tab_control_dragger()
		draw_dragger("libraryrepeatx", dx, dy, dw, temp_edit.block_repeat[X], 1 / 10, 1, 1000, 1, 1, tab.library.tbx_repeat_x, action_lib_block_repeat, capwid)
		tab_next()
		
		axis_edit = test(setting_z_is_up, Y, Z)
		tab_control_dragger()
		draw_dragger("libraryrepeaty", dx, dy, dw, temp_edit.block_repeat[axis_edit], 1 / 10, 1, 1000, 1, 1, tab.library.tbx_repeat_y, action_lib_block_repeat, capwid)
		tab_next()
		
		axis_edit = test(setting_z_is_up, Z, Y)
		tab_control_dragger()
		draw_dragger("libraryrepeatz", dx, dy, dw, temp_edit.block_repeat[axis_edit], 1 / 10, 1, 1000, 1, 1, tab.library.tbx_repeat_z, action_lib_block_repeat, capwid)
		tab_next()
	}
}
