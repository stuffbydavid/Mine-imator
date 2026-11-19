function action_block_settings_filter_add(value)
{
	array_add(popup_current.filter_array, value)
	popup_current.block_select = null
}
