function action_block_settings_tl_type(type)
{
	var popup = popup_block_settings;
	if (popup.tl_all_types)
	{
		popup.tl_types = []
		for (var i = 0; i < ds_list_size(mc_assets.block_tl_type_list); i++)
			array_add(popup.tl_types, mc_assets.block_tl_type_list[|i])

		popup.tl_all_types = false
	}

	var selected = [];
	for (var i = 0; i < array_length(popup.tl_types); i++)
		if (popup.tl_types[i] != type)
			array_add(selected, popup.tl_types[i])

	if (array_length(selected) = array_length(popup.tl_types))
		array_add(selected, type)

	popup.tl_types = selected
}
