/// @desc Returns the workbench selector height after reserving space for settings.
/// @arg [settingsheight]
/// @arg [minimumitems]

function bench_get_list_height(settingshei = null, minitems = null)
{
	var footerh, minh;
	if (minitems = null)
		minitems = list_minimum_items
	
	footerh = bench_buttons_hidden ? 24 : bench_footer_height + 4
	minh = list_header_height + 12 + max(68 * 3, minitems * ui_small_height)
	
	bench_list_height_min = minh
	bench_list_height = minh
	
	if (settingshei = null)
		return minh

	bench_list_height = max(minh, content_y + content_height - dy - footerh - settingshei)
	
	return bench_list_height
}
