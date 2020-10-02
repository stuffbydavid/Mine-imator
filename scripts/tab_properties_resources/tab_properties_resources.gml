/// tab_properties_resources()

var capwid;

// Preview selected resource
tab_control(160)
preview_draw(res_preview, dx + floor(dw / 2) - 80, dy, 160, 160)
tab_next()

// List
var listh = 256;
if (content_direction = e_scroll.HORIZONTAL)
	listh = max(135, dh - (dy - dy_start) - 35)

if (tab_control(listh))
{
	listh = dh - (dy - dy_start - 18) - 30
	tab_control_h = listh
}
sortlist_draw(tab.resources.list, dx, dy, dw, listh, res_edit)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("resourcesnew", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.IMPORT))
	action_toolbar_import_asset()
	
if (draw_button_normal("resourcesremove", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, (res_edit && res_edit != mc_res), icons.DELETE))
	action_res_remove()
	
if (draw_button_normal("resourcesreload", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, (res_edit && res_edit != mc_res), icons.RELOAD))
	action_res_reload()
	
if (draw_button_normal("resourcesreplace", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, (res_edit && res_edit != mc_res), icons.BROWSE))
	action_res_replace()
	
tab_next()

if (res_edit = null)
	return 0

if (res_edit.type = e_res_type.PACK)
{
	capwid = text_caption_width("resourcespackimage", "resourcespackimagecharacter", "resourcespackimagecolormap", "resourcespackimageparticles")
	
	tab_control(24)
	draw_button_menu("resourcespackimage", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_image, text_get("resourcespack" + res_preview.pack_image), action_res_preview_pack_image, null, null, capwid)
	tab_next()
	
	switch (res_preview.pack_image)
	{
		case "modeltextures":
		{
			tab_control(24)
			draw_button_menu("resourcespackimagemodeltexture", e_menu.LIST, dx, dy, dw, 24, res_preview.pack_model_texture, res_preview.pack_model_texture, action_res_preview_pack_model_texture, null, null, capwid)
			tab_next()
			break
		}
		case "blocksheet":
		{
			tab_control_checkbox()
			draw_label(text_get("resourcespackimageblocksheet") + ":", dx, dy)
			draw_radiobutton("resourcespackimageblocksheetstatic", dx + capwid, dy, 0, !res_preview.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
			draw_radiobutton("resourcespackimageblocksheetanimated", dx + capwid + floor((dw - capwid) * 0.5), dy, 1, res_preview.pack_block_sheet_ani, action_res_preview_pack_block_sheet_ani)
			tab_next()
			break
		}
		case "colormap":
		{
			tab_control_checkbox()
			draw_label(text_get("resourcespackimagecolormap") + ":", dx, dy)
			draw_radiobutton("resourcespackimagecolormapgrass", dx + capwid, dy, 0, res_preview.pack_colormap = 0, action_res_preview_pack_colormap)
			draw_radiobutton("resourcespackimagecolormapfoliage", dx + capwid + floor((dw - capwid) * 0.5), dy, 1, res_preview.pack_colormap = 1, action_res_preview_pack_colormap)
			tab_next()
			break
		}
		case "particlesheet":
		{
			tab_control_checkbox()
			draw_label(text_get("resourcespackimageparticles") + ":", dx, dy)
			draw_radiobutton("resourcespackimageparticlesimage1", dx + capwid, dy, 0, res_preview.pack_particles = 0, action_res_preview_pack_particles)
			draw_radiobutton("resourcespackimageparticlesimage2", dx + capwid + floor((dw - capwid) * 0.5), dy, 1, res_preview.pack_particles = 1, action_res_preview_pack_particles)
			tab_next()
			break
		}
	}
}
else if (res_edit.type = e_res_type.ITEM_SHEET)
{
	// Sheet size
	capwid = text_caption_width("resourcesitemsheetsizewidth", "resourcesitemsheetsizeheight")
		
	axis_edit = X
	tab_control_dragger()
	draw_dragger("resourcesitemsheetsizewidth", dx, dy, dw, res_edit.item_sheet_size[X], 1 / 10, 1, no_limit, item_sheet_width, 1, tab.resources.tbx_item_sheet_width, action_res_item_sheet_size, capwid)
	tab_next()
		
	axis_edit = Y
	tab_control_dragger()
	draw_dragger("resourcesitemsheetsizeheight", dx, dy, dw, res_edit.item_sheet_size[Y], 1 / 10, 1, no_limit, item_sheet_height, 1, tab.resources.tbx_item_sheet_height, action_res_item_sheet_size, capwid)
	tab_next()
}
else if (res_edit.scenery_structure)
{
	if (res_edit.scenery_palette_size > 0)
	{
		tab_control(24)
		draw_button_menu("resourcesscenerystructurepalette", e_menu.LIST, dx, dy, dw, 24, res_edit.scenery_palette, text_get("resourcesscenerystructurepalettenumber", res_edit.scenery_palette + 1), action_res_scenery_palette)
		tab_next()
		
		/*
		tab_control_meter()
		draw_meter("resourcesscenerystructurepalette", dx, dy, dw, res_edit.scenery_palette, 64, 0, res_edit.scenery_palette_size - 1, 0, 1, tab.resources.tbx_scenery_palette, action_res_scenery_palette)
		tab_next()
		*/
	}
	
	tab_control_meter()
	draw_meter("resourcesscenerystructureintegrity", dx, dy, dw, round(res_edit.scenery_integrity * 100), 64, 0, 100, 100, 1, tab.resources.tbx_scenery_integrity, action_res_scenery_integrity)
	tab_next()
	
	tab_control_checkbox()
	draw_checkbox("resourcesscenerystructureintegrityinvert", dx, dy, res_edit.scenery_integrity_invert, action_res_scenery_integrity_invert)
	tab_next()
}

if (res_edit.filename != "") // Filename
{
	var wid = text_max_width("resourcesfilenameopen") + 20;
	capwid = text_caption_width("resourcesfilename")
	
	tab_control(24)
	tip_wrap = false
	tip_set(string_remove_newline(project_folder + "\\" + res_edit.filename), dx, dy, dw - wid, 24)
	
	draw_label(text_get("resourcesfilename") + ":", dx, dy + 12, fa_left, fa_middle)
	draw_label(string_limit(string_remove_newline(res_edit.filename), dw - capwid - wid), dx + capwid, dy + 12, fa_left, fa_middle)
	
	if (res_edit.type != e_res_type.SCENERY)
		if (draw_button_normal("resourcesfilenameopen", dx + dw - wid, dy, wid, 24))
			open_url(project_folder + "\\" + res_edit.filename)
			
	tab_next()
}
