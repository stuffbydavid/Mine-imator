/// @desc Draw the per-resource animation and block filter controls.

function popup_block_settings_draw()
{
	var popup, res;
	popup = popup_block_settings
	res = popup.resource
	
	// Timeline blocks
	if (array_length(popup.tl_available_types) > 0)
	{
		draw_label(text_get("block_settings/timeline_blocks"), dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		dy += 32
		
		draw_tooltip_label("block_settings/timeline_blocks_tip", icons.INFO, e_toast.INFO)
		
		tab_set_columns(true, popup.tl_columns)

		var checkedcount = 0;
		for (var i = 0; i < array_length(popup.tl_available_types); i++)
		{
			var type, amount, selected, label;
			type = popup.tl_available_types[i]
			amount = popup.tl_available_amounts[i]
			label = popup.tl_available_labels[i]

			selected = (popup.tl_all_types || array_contains(popup.tl_types, type))
			checkedcount += (selected ? amount : 0)
			tab_control_checkbox()

			if (draw_checkbox("block_settings/timeline/" + type, dx, dy, selected, null, "", label))
				action_block_settings_tl_type(type)

			tab_next()
		}

		tab_set_columns(false)
		dy += 8
		
		if (checkedcount > scenery_timeline_warning)
			draw_tooltip_label("block_settings/timeline_blocks_warning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	}
	
	if (!popup.during_load)
	{
		dw = dw / 2 - 10

		// Palette and structure integrity
		if (res.scenery_structure)
		{
			tab_control_meter()

			draw_meter("block_settings/integrity", dx, dy, dw, round(popup.scenery_integrity * 100), 0, 100, 100, 1, popup.tbx_scenery_integrity, action_block_settings_integrity)

			if (res.scenery_palette_size > 0)
				draw_button_menu("block_settings/palette", e_menu.LIST, dx + dw + 20, dy, dw, 24, popup.scenery_palette, text_get("block_settings/palette_number", popup.scenery_palette + 1), action_block_settings_palette)

			tab_next()
			
			dy += 4
		}

		// Randomize blocks
		if (res.type = e_res_type.SCHEMATIC)
		{
			tab_control_switch()
			draw_switch("block_settings/randomize", dx, dy, popup.scenery_randomize, action_block_settings_randomize, "block_settings/randomize_tip")
			tab_next()
		}

		// Filter settings
		draw_block_settings_filter()
	}

	dy += 12
	
	// Confirm
	tab_control_button_label()
	if (draw_button_label("block_settings/confirm", content_x + content_width / 2, content_y + content_height - tab_control_h - 12, 100, null, e_button.PRIMARY, null, e_anchor.CENTER))
		action_block_settings_confirm()
	tab_next()
}
