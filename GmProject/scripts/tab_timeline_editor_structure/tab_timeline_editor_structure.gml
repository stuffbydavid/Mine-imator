function tab_timeline_editor_structure()
{
	var scenery, typename, setx, dividew;
	scenery = (tl_edit.type = e_tl_type.SCENERY)
	typename = (scenery ? "scenery" : "structure")
	dividew = content_width - floor(tab.scroll.needed * 12)

	// Settings
	setx = dx + dw - 24
	tab_control(24)

	if (draw_button_icon("timeline_editor/export_schematic", setx, dy, 24, 24, false, icons.ASSET_EXPORT, null, false, "timeline_editor/export_schematic_" + typename + "_tip"))
		action_tl_export_schematic()
	setx -= 28

	if (draw_button_icon("timeline_editor/create_template", setx, dy, 24, 24, false, icons.ASSET_ADD, null, false, "timeline_editor/create_template_" + typename + "_tip"))
		action_tl_create_scenery_temp()
	setx -= 28

	if (scenery)
	{
		draw_button_icon("timeline_editor/restore_blocks", setx, dy, 24, 24, false, icons.RESET, null, false, "timeline_editor/restore_blocks_tip")
		setx -= 28
	}

	draw_label_value(dx, dy, setx - dx, 24, text_get(scenery ? "timeline_editor/blocks_modified" : "timeline_editor/blocks"), string(array_length(tl_edit.blocks_added)))
	tab_next()
	dy += 8

	var editing, editname, editwid, settingswid, padding, buttonx, stacked;
	editing = (place_build && build_structure = tl_edit)
	editname = (editing ? "timeline_editor/confirm" : "timeline_editor/edit")

	draw_set_font(font_button)
	settingswid = string_width(text_get("timeline_editor/block_settings")) + 60
	editwid = string_width(text_get(editname)) + 60

	stacked = scenery && editwid + settingswid + 8 > dw
	buttonx = dx + (dw - (scenery && !stacked ? editwid + settingswid + 8 : editwid)) / 2
	
	tab_control_button_label()
	if (draw_button_label(editname, buttonx, dy, editwid, editing ? icons.TICK : icons.PENCIL))
	{
		if (editing)
			action_toolbar_build_mode()
		else
		{
			var structure = tl_edit;
			if (!place_build)
				action_toolbar_build_mode()

			action_build_structure_select(structure)
		}
	}

	if (scenery)
	{
		if (stacked)
		{
			tab_next()
			tab_control_button_label()
		}

		buttonx = (stacked ? dx + (dw - settingswid) / 2 : buttonx + editwid + 8)
		var res = (tl_edit.temp != null ? tl_edit.temp.scenery : null);
		if (draw_button_label("timeline_editor/block_settings", buttonx, dy, settingswid, icons.BLOCK, e_button.PRIMARY, null, e_anchor.LEFT, res = null || !res.ready))
		{
			action_res_list(res)
			popup_block_settings_show(res)
		}
	}

	tab_next()
}
