function action_block_settings_filter_remove(value)
{
	var old, values;
	old = popup_current.filter_array
	values = []
	
	for (var i = 0; i < array_length(old); i++)
		if (old[i] != value)
			array_add(values, old[i])

	popup_current.filter_array = values
	popup_current.filter_select = null
}
