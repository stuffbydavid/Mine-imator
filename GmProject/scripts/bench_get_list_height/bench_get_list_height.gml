/// @desc Returns the workbench selector height after reserving space for settings.
/// @arg [settingsheight]
/// @arg [minimumheight]

function bench_get_list_height(settingshei = null, minhei = null)
{
	var footerh;
	if (minhei = null)
		minhei = list_header_height + list_minimum_items * ui_small_height
	
	footerh = bench_buttons_hidden ? 24 : bench_footer_height
	bench_list_height_min = minhei
	bench_list_height = minhei
	
	if (settingshei = null)
		return minhei

	bench_list_height = max(minhei, content_y + content_height - dy - footerh - settingshei)
	
	return bench_list_height
}
