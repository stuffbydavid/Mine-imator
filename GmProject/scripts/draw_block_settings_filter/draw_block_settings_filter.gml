/// @desc Draws a two-list block filter editor for the current popup.

function draw_block_settings_filter()
{
	var popup, blocklist, filterlist;
	popup = popup_current
	blocklist = popup.block_list
	filterlist = popup.filter_list

	tab_control_switch()
	draw_switch("block_settings/filter_enabled", dx, dy, popup.filter_enabled, action_block_settings_filter_enabled)
	tab_next()

	if (!popup.filter_enabled)
		return 0

	tab_control_togglebutton()
	togglebutton_add("block_settings/filter_remove", null, e_block_filter.REMOVE, popup.filter_mode = e_block_filter.REMOVE, action_block_settings_filter_mode)
	togglebutton_add("block_settings/filter_keep", null, e_block_filter.KEEP, popup.filter_mode = e_block_filter.KEEP, action_block_settings_filter_mode)
	draw_togglebutton("block_settings/filter_mode", dx, dy)
	tab_next()

	dy += 8
	
	dw = content_width - 24

	draw_tooltip_label("block_settings/filter_tip", icons.INFO, e_toast.INFO)
	dy += 8
	
	tab_control_sortlist(blocklist)

	sortlist_draw(blocklist, dx, dy, dw / 2 - 20, tab_control_h, popup.block_select, false, text_get("block_settings/filter_blocks"))
	sortlist_draw(filterlist, dx + dw / 2 + 20, dy, dw / 2 - 20, tab_control_h, popup.filter_select, false, text_get("block_settings/filter_filtered"))

	if (draw_button_icon("block_settings/filter_right", dx + dw / 2 - 12, dy + tab_control_h / 2 - 16, 24, 24, false, icons.CHEVRON_RIGHT, null, popup.block_select = null))
	{
		sortlist_add(filterlist, popup.block_select)
		sortlist_remove(blocklist, popup.block_select)
		sortlist_update(filterlist)
		sortlist_update(blocklist)
		action_block_settings_filter_add(popup.block_select)
	}

	if (draw_button_icon("block_settings/filter_left", dx + dw / 2 - 12, dy + tab_control_h / 2 + 16, 24, 24, false, icons.CHEVRON_LEFT, null, popup.filter_select = null))
	{
		var index;
		for (index = 0; index < ds_list_size(blocklist.list); index++)
			if (blocklist.list[|index] > popup.filter_select)
				break

		sortlist_add(blocklist, popup.filter_select, index)
		sortlist_remove(filterlist, popup.filter_select)
		sortlist_update(blocklist)
		sortlist_update(filterlist)
		action_block_settings_filter_remove(popup.filter_select)
	}

	tab_next()
}
