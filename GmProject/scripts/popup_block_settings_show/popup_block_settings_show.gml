/// @desc Open block settings for a scenery resource.
/// @arg resource
/// @arg [duringload]
/// @arg [timeline]
/// @arg [historyobject]
/// @arg [startplacing]

function popup_block_settings_show(res, duringload = false, tl = null, hobj = null, startplacing = false)
{
	with (popup_block_settings)
	{
		height_ready = false
		resource = res
		
		during_load = duringload
		width = duringload ? 500 : app.popup_world_settings.width
		create_tl = tl
		create_hobj = hobj
		create_place = startplacing
		close_script = (tl != null ? action_block_settings_confirm : null)

		tl_all_types = res.scenery_tl_all_types
		tl_types = array_copy_1d(res.scenery_tl_types)
		tl_available_types = []
		tl_available_labels = []
		tl_available_amounts = []
		tl_available_tips = []
		
		scenery_integrity = res.scenery_integrity
		scenery_palette = res.scenery_palette
		scenery_randomize = res.scenery_randomize

		// Parse available block timeline types
		var maxlabelwid = 0;
		for (var i = 0; i < ds_list_size(mc_assets.block_tl_type_list); i++)
		{
			var type, amount, label, tip;
			type = mc_assets.block_tl_type_list[|i]
			amount = value_get_real(res.scenery_tl_types_count_map[?type], 0)
			if (amount <= 0)
				continue

			label = minecraft_asset_get_name("block", type) + " (" + string(amount) + ")"
			tip = ""
			if (type = "sign")
				tip = "block_settings/timeline_required_sign_tip"
			else if (ds_map_exists(mc_assets.block_tl_required_map, type))
				tip = "block_settings/timeline_required_tip"

			array_add(tl_available_types, type)
			array_add(tl_available_labels, label)
			array_add(tl_available_amounts, amount)
			array_add(tl_available_tips, tip)

			maxlabelwid = max(maxlabelwid, string_width_font(label, app.font_label) + (tip != "" ? 48 : 40))
		}

		tl_columns = (maxlabelwid > (width - 48) / 4) ? 3 : 4

		filter_enabled = res.scenery_filter_enabled
		filter_mode = res.scenery_filter_mode
		filter_array = array_copy_1d(res.scenery_filter_array)
		block_select = null
		filter_select = null

		if (!duringload)
			offset_y = filter_enabled ? 0 : -app.window_height * 0.1
		else
			offset_y = 0

		caption = text_get("block_settings/caption", res.display_name)
		if (filter_enabled && (filter_mode = e_block_filter.KEEP || array_length(filter_array) > 0))
			caption += " " + text_get("block_settings/caption_filtered")

		with (res)
			res_load_scenery_filter_mask()

		// Update filter lists
		sortlist_clear(block_list)
		sortlist_clear(filter_list)

		block_list.search = (block_list.search_tbx.text != "")
		filter_list.search = (filter_list.search_tbx.text != "")

		for (var i = 0; i < ds_list_size(mc_assets.block_list); i++)
		{
			var block, amount;
			block = mc_assets.block_list[|i]
			amount = value_get_real(res.scenery_block_map[?block.name], 0)

			if (array_contains(filter_array, i))
				sortlist_add(filter_list, i)
			else if (amount > 0)
				sortlist_add(block_list, i)
		}

		block_list.height_items = 8
		filter_list.height_items = block_list.height_items
	}

	sortlist_update(popup_block_settings.block_list)
	sortlist_update(popup_block_settings.filter_list)

	// Show or switch popup
	if (duringload)
		popup_switch(popup_block_settings)
	else
		popup_show(popup_block_settings)
}
